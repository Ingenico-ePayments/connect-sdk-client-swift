pipeline {
 
    agent {
        node {
            label 'macserver01'
        }
    }

    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: '30', artifactNumToKeepStr: '5', daysToKeepStr: '150', numToKeepStr: '5'))
        disableConcurrentBuilds()
        timeout(time: 15, unit: 'MINUTES')
    }

    triggers {
        cron ('H 2 * * *')
    }

    // Required for keytool
    tools {
        jdk 'JDK 8.0'
    }


    environment {
        DEVELOPMENT_CERTIFICATE="development_certificate.p12"
        PROVISIONING_PROFILE_CONTENTS="pp_contents.plist"
        PROVISIONING_PROFILE_UUID=""
        MY_KEYCHAIN="ingenico-swift-sdk.temp.keychain"
        MY_KEYCHAIN_PASSWORD="<random string>" // No need to have this be a very secret string, as the keychain will only live during build
        LANG="en_US.UTF-8"      // Fixes issue with xcpretty
        LANGUAGE="en_US.UTF-8"  // Fixes issue with xcpretty
        LC_ALL="en_US.UTF-8"    // Fixes issue with xcpretty
    }


    stages {
         
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

         
        stage('Prepare certificate and provisioning profile') {
            steps {
                withCredentials([
                        certificate(aliasVariable: '', credentialsId: 'ios-generic-isaac-dev-certificate', keystoreVariable: 'DEVELOPMENT_KEYSTORE', passwordVariable: 'DEVELOPMENT_PASSWORD'),
                ]) {
                    sh '''
                        # Export the certificate in Jenkins to a p12 file that can be read by Keychain
                        keytool -importkeystore -srckeystore "$DEVELOPMENT_KEYSTORE" -destkeystore "$DEVELOPMENT_CERTIFICATE" -srcstoretype JKS -deststoretype PKCS12 -srcstorepass "$DEVELOPMENT_PASSWORD" -deststorepass "$DEVELOPMENT_PASSWORD"
 
                        # Create temp keychain
                        security create-keychain -p "$MY_KEYCHAIN_PASSWORD" "$MY_KEYCHAIN"
                        # Append temp keychain to the user domain
                        security list-keychains -d user -s "$MY_KEYCHAIN" $(security list-keychains -d user | sed s/\\\"//g)
                        # Remove relock timeout
                        security set-keychain-settings "$MY_KEYCHAIN"
                        # Unlock keychain
                        security unlock-keychain -p "$MY_KEYCHAIN_PASSWORD" "$MY_KEYCHAIN"
                        # Add development certificate to keychain
                        security import $DEVELOPMENT_CERTIFICATE -k "$MY_KEYCHAIN" -P "$DEVELOPMENT_PASSWORD" -A
                        # Programmatically derive the identity
                        CERT_IDENTITY=\$(security find-identity -v -p codesigning "$MY_KEYCHAIN" | head -1 | grep '"' | sed -e 's/[^"]*"//' -e 's/".*//')
                        # Enable codesigning from a non user interactive shell
                        security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$MY_KEYCHAIN_PASSWORD" -D "$CERT_IDENTITY" -t private "$MY_KEYCHAIN"
                    '''
                }
            }
 
            post {
                always {
                    script {
                        if (fileExists(env.DEVELOPMENT_CERTIFICATE)) {
                            sh 'rm -f "$DEVELOPMENT_CERTIFICATE"'
                        }
 
                        if (fileExists(env.PROVISIONING_PROFILE_CONTENTS)) {
                            sh 'rm -f "$PROVISIONING_PROFILE_CONTENTS"'
                        }
                    }
                }
            }
        }

        stage('Carthage build') {
            steps {
                sh '''
                    #!/usr/bin/env bash
                    set -euo pipefail

                    xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
                    trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

                    # For Xcode 13 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
                    # the build will fail on lipo due to duplicate architectures.
                    echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1300 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
                    echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

                    export XCODE_XCCONFIG_FILE="$xcconfig"

                    rm -r Carthage
                
                    cat Cartfile.resolved
                
                    carthage bootstrap --platform ios --use-xcframeworks
                '''
            }  
        }

        stage('Swiftlint') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh 'swiftlint --reporter html > lint-report.html || true'

                    script {
                        def reportContents = readFile "lint-report.html"
                        if (reportContents.contains("error") || reportContents.contains("warning")) {
                            error("Swiftlint error / warning found.")
                        }
                    }
                }
                script {
                    archiveArtifacts allowEmptyArchive: false,
                    artifacts: 'lint-report.html',
                    onlyIfSuccessful: false
                }
            }
        }

        stage('Periphery scan') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh 'periphery scan --config .periphery.yml > periphery-scan-report.txt'

                    script {
                        def reportContents = readFile "periphery-scan-report.txt"
                        if (reportContents.contains("warning")) {
                            error("Unused code found.")
                        }
                    }
                }
                script {
		            archiveArtifacts allowEmptyArchive: false,
                    artifacts: 'periphery-scan-report.txt',
                    onlyIfSuccessful: false			
		        }
            }
        } 
 
        // Build/Test/Release etc. stages go here
        stage('Build, Test app & Publish test results') {
            steps {
                // Remove old reports first
                sh '''xcodebuild -project IngenicoConnectKit.xcodeproj \
                    -sdk iphonesimulator \
                    -destination "platform=iOS simulator,name=iPhone 13,OS=15.5" \
                    -scheme IngenicoConnectKit \
                    DEVELOPMENT_TEAM=S453L3NXGS \
                    OTHER_CODE_SIGN_FLAGS="--keychain $MY_KEYCHAIN" \
                    clean build \
                    clean test | xcpretty -r junit || true
                '''
                junit testResults: 'build/reports/*.xml', allowEmptyResults: false, testDataPublishers: [[$class: 'AttachmentPublisher']]
            }
        }
    }
 
 
    // Cleanup temporary keychain
    post {
        failure {
            emailext (
                subject: "${currentBuild.currentResult}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: '${JELLY_SCRIPT, template="html"}',
		        to: 'leon.stemerdink@iodigital.com, esmee.kluijtmans@iodigital.com',
                recipientProviders: [developers(), culprits(), requestor()]
            )
        }
        
        always {
            sh '''
                # Delete temporary keychain (Command fails if the keychain was never created; not a problem)
                security delete-keychain "$MY_KEYCHAIN"
            '''
        }
    }
}

