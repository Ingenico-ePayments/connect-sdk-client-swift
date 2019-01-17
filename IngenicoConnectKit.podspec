Pod::Spec.new do |s|

  s.name          = "IngenicoConnectKit"
  s.version       = "3.2.0"
  s.summary       = "Ingenico Connect Swift SDK"
  s.description   = <<-DESC
                    This native iOS SDK facilitates handling payments in your apps
                    using the Ingenico ePayments platform of Ingenico ePayments.
                    DESC

  s.homepage      = "https://github.com/Ingenico-ePayments/connect-sdk-client-swift"
  s.license       = { :type => "MIT", :file => "LICENSE.txt" }
  s.author        = "Ingenico"
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/Ingenico-ePayments/connect-sdk-client-swift.git", :tag => s.version }
  s.source_files  = "IngenicoConnectKit/**/*.swift"
  s.resource      = "IngenicoConnectKit/IngenicoConnectKit.bundle"
  s.swift_version = "4.1"
  
  s.dependency 'Alamofire', '~> 4.7.3'
  s.dependency 'CryptoSwift', '0.12.0'

end
