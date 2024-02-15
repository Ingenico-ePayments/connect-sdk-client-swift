//
//  ConnectSDK.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 24/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

public class ConnectSDK {
    public static var clientApi: ClientApi {
        guard let api = _clientApi else {
            fatalError(ConnectSDKError.connectSDKNotInitialized.localizedDescription)
        }

        return api
    }
    private static var _clientApi: ClientApi?

    public static var connectSDKConfiguration: ConnectSDKConfiguration {
        guard let sdkConfig = _connectSDKConfiguration else {
            fatalError(ConnectSDKError.connectSDKNotInitialized.localizedDescription)
        }

        return sdkConfig
    }
    private static var _connectSDKConfiguration: ConnectSDKConfiguration?

    public static var paymentConfiguration: PaymentConfiguration {
        guard let paymentConfig = _paymentConfiguration else {
            fatalError(ConnectSDKError.connectSDKNotInitialized.localizedDescription)
        }

        return paymentConfig
    }
    private static var _paymentConfiguration: PaymentConfiguration?

    private static let encryptor = Encryptor()
    private static let joseEncryptor = JOSEEncryptor(encryptor: encryptor)

    public static func initialize(
        connectSDKConfiguration: ConnectSDKConfiguration,
        paymentConfiguration: PaymentConfiguration
    ) {
        self._clientApi = ClientApi(
            sdkConfiguration: connectSDKConfiguration,
            paymentConfiguration: paymentConfiguration
        )
        self._connectSDKConfiguration = connectSDKConfiguration
        self._paymentConfiguration = paymentConfiguration
    }

    public static func close() {
        self._clientApi = nil
        self._connectSDKConfiguration = nil
        self._paymentConfiguration = nil
    }

    public static func encryptPaymentRequest(
        _ paymentRequest: PaymentRequest,
        success: @escaping (_ preparedPaymentRequest: PreparedPaymentRequest) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApi.publicKey(
            success: { publicKeyResponse in
                let publicKeyAsData = publicKeyResponse.encodedPublicKey.decode()
                guard let strippedPublicKeyAsData = self.encryptor.stripPublicKey(data: publicKeyAsData) else {
                    failure(ConnectSDKError.publicKeyDecodeError)
                    return
                }
                let tag = "globalcollect-sdk-public-key-swift"

                self.encryptor.deleteRSAKey(withTag: tag)
                self.encryptor.storePublicKey(publicKey: strippedPublicKeyAsData, tag: tag)

                guard let publicKey = self.encryptor.RSAKey(withTag: tag) else {
                    failure(ConnectSDKError.rsaKeyNotFound)
                    return
                }

                let paymentRequestJSON =
                    self.preparePaymentRequestJSON(
                        forClientSessionId: connectSDKConfiguration.sessionConfiguration.clientSessionId,
                        paymentRequest: paymentRequest
                    )
                let encryptedFields =
                    self.joseEncryptor.encryptToCompactSerialization(
                        JSON: paymentRequestJSON,
                        withPublicKey: publicKey,
                        keyId: publicKeyResponse.keyId
                    )
                let encodedClientMetaInfo = clientApi.base64EncodedClientMetaInfo
                let preparedRequest =
                    PreparedPaymentRequest(
                        encryptedFields: encryptedFields,
                        encodedClientMetaInfo: encodedClientMetaInfo
                    )
                success(preparedRequest)
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    private static func preparePaymentRequestJSON(
        forClientSessionId clientSessionId: String,
        paymentRequest: PaymentRequest
    ) -> String {
        var paymentRequestJSON = String()

        guard let paymentProduct = paymentRequest.paymentProduct else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid payment product"),
                reason: "Payment product is invalid"
            ).raise()
            // Return is mandatory but will never be reached because of the exception above.
            return "Invalid payment product"
        }

        let clientSessionId = "{\"clientSessionId\": \"\(clientSessionId)\", "
        paymentRequestJSON += clientSessionId
        let nonce = "\"nonce\": \"\(self.encryptor.generateUUID())\", "
        paymentRequestJSON += nonce
        let paymentProductJSON = "\"paymentProductId\": \(paymentProduct.identifier), "
        paymentRequestJSON += paymentProductJSON

        if let accountOnFile = paymentRequest.accountOnFile {
            paymentRequestJSON += "\"accountOnFileId\": \(accountOnFile.identifier), "
        }
        if paymentRequest.tokenize {
            let tokenize = "\"tokenize\": true, "
            paymentRequestJSON += tokenize
        }
        if let fieldVals = paymentRequest.unmaskedFieldValues,
            let values = self.keyValueJSONFromDictionary(dictionary: fieldVals) {
            let paymentValues = "\"paymentValues\": \(values)}"
            paymentRequestJSON += paymentValues
        }

        return paymentRequestJSON
    }

    private static func keyValueJSONFromDictionary(dictionary: [String: String]) -> String? {
        let keyValuePairs = self.keyValuePairs(from: dictionary)
        guard let JSONAsData = try? JSONSerialization.data(withJSONObject: keyValuePairs) else {
            Macros.DLog(message: "Unable to create JSON data from dictionary")
            return nil
        }

        return String(bytes: JSONAsData, encoding: String.Encoding.utf8)
    }

    private static func keyValuePairs(from dictionary: [String: String]) -> [[String: String]] {
        var keyValuePairs = [[String: String]]()
        for (key, value) in  dictionary {
            let pair = ["key": key, "value": value]
            keyValuePairs.append(pair)
        }
        return keyValuePairs
    }
}
