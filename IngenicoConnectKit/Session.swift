//
//  Session.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import PassKit

public class Session {
    public var communicator: C2SCommunicator
    public var assetManager: AssetManager
    public var encryptor: Encryptor
    public var joseEncryptor: JOSEEncryptor
    public var stringFormatter: StringFormatter

    public var paymentProducts = BasicPaymentProducts()
    public var paymentProductGroups = BasicPaymentProductGroups()

    public var paymentProductMapping = [AnyHashable: Any]()
    public var paymentProductGroupMapping = [AnyHashable: Any]()
    public var directoryEntriesMapping = [AnyHashable: Any]()

    public var baseURL: String? {
        get {
            return communicator.configuration.baseURL
        }
        set {
            if let newValue = newValue {
                communicator.configuration.baseURL = newValue

            }
        }
    }
    public var assetsBaseURL: String? {
        get {
            return communicator.configuration.assetsBaseURL
        }
        set {
            if let newValue = newValue {
                communicator.configuration.assetsBaseURL = newValue
            }
        }
    }

    public var iinLookupPending = false

    public init(
        communicator: C2SCommunicator,
        assetManager: AssetManager,
        encryptor: Encryptor,
        JOSEEncryptor: JOSEEncryptor,
        stringFormatter: StringFormatter
    ) {
        self.communicator = communicator
        self.assetManager = assetManager
        self.encryptor = encryptor
        self.joseEncryptor = JOSEEncryptor
        self.stringFormatter = stringFormatter
    }

    public init(
        clientSessionId: String,
        customerId: String,
        baseURL: String,
        assetBaseURL: String,
        appIdentifier: String
    ) {
        let assetManager = AssetManager()
        let stringFormatter = StringFormatter()
        let encryptor = Encryptor()
        let configuration = C2SCommunicatorConfiguration(clientSessionId: clientSessionId,
                                                         customerId: customerId,
                                                         baseURL: baseURL,
                                                         assetBaseURL: assetBaseURL,
                                                         appIdentifier: appIdentifier)
        let communicator = C2SCommunicator(configuration: configuration)
        let jsonEncryptor = JOSEEncryptor(encryptor: encryptor)

        self.communicator = communicator
        self.assetManager = assetManager
        self.encryptor = encryptor
        self.joseEncryptor = jsonEncryptor
        self.stringFormatter = stringFormatter

    }

    @available(*, deprecated, message: "Use init(clientSessionId:customerId:baseURL:assetsURL:appIdentifier:) instead")
    public init(
        clientSessionId: String,
        customerId: String,
        region: Region,
        environment: Environment,
        appIdentifier: String
    ) {
        let assetManager = AssetManager()
        let stringFormatter = StringFormatter()
        let encryptor = Encryptor()
        let configuration = C2SCommunicatorConfiguration(clientSessionId: clientSessionId,
                                                         customerId: customerId,
                                                         region: region,
                                                         environment: environment,
                                                         appIdentifier: appIdentifier)
        let communicator = C2SCommunicator(configuration: configuration)
        let jsonEncryptor = JOSEEncryptor(encryptor: encryptor)

        self.communicator = communicator
        self.assetManager = assetManager
        self.encryptor = encryptor
        self.joseEncryptor = jsonEncryptor
        self.stringFormatter = stringFormatter
    }

    public func paymentProducts(
        for context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        communicator.paymentProducts(forContext: context, success: { paymentProducts in
            self.paymentProducts = paymentProducts
            self.paymentProducts.stringFormatter = self.stringFormatter
            self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
            self.assetManager.updateImagesAsync(
                for: paymentProducts.paymentProducts,
                baseURL: self.communicator.assetsBaseURL
            ) {
                success(paymentProducts)
            }

        }, failure: { error in
            failure(error)
        })
    }

    public func paymentProductNetworks(
        forProductId paymentProductId: String,
        context: PaymentContext,
        success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        communicator.paymentProductNetworks(
            forProduct: paymentProductId,
            context: context,
            success: { paymentProductNetworks in
                success(paymentProductNetworks)
            },
            failure: { error in
                failure(error)
            }
        )
    }

    @available(*, deprecated, message: "Use customerDetails(String:[String,String]:String:) instead")
    public func customerDetails(
        forProductId productId: String,
        withLookupValues lookupValues: [[String: String]],
        countryCode: CountryCode,
        success: @escaping (_ paymentProduct: CustomerDetails) -> Void,
        failure: @escaping  (_ error: Error) -> Void
    ) {
        communicator.customerDetails(
            forProductId: productId,
            withLookupValues: lookupValues,
            countryCode: countryCode.rawValue,
            success: success,
            failure: failure
        )
    }

    public func customerDetails(
        forProductId productId: String,
        withLookupValues lookupValues: [[String: String]],
        countryCode: String,
        success: @escaping (_ paymentProduct: CustomerDetails) -> Void,
        failure: @escaping  (_ error: Error) -> Void
    ) {
        communicator.customerDetails(
            forProductId: productId,
            withLookupValues: lookupValues,
            countryCode: countryCode,
            success: success,
            failure: failure
        )
    }

    public func paymentProductGroups(
        for context: PaymentContext,
        success: @escaping (_ paymentProductGroups: BasicPaymentProductGroups) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        communicator.paymentProductGroups(forContext: context, success: { paymentProductGroups in
            self.paymentProductGroups = paymentProductGroups
            self.paymentProductGroups.stringFormatter = self.stringFormatter
            self.assetManager.initializeImages(for: paymentProductGroups.paymentProductGroups)
            self.assetManager.updateImagesAsync(
                for: paymentProductGroups.paymentProductGroups,
                baseURL: self.communicator.assetsBaseURL
            )
            success(paymentProductGroups)
        }, failure: { error in
            failure(error)
        })
    }

    public func paymentItems(
        for context: PaymentContext,
        groupPaymentProducts: Bool,
        success: @escaping (_ paymentItems: PaymentItems) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        communicator.paymentProducts(forContext: context, success: { paymentProducts in
            self.paymentProducts = paymentProducts
            self.paymentProducts.stringFormatter = self.stringFormatter
            // self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
            self.assetManager.updateImagesAsync(
                for: paymentProducts.paymentProducts,
                baseURL: self.communicator.assetsBaseURL
            ) {
                self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
                if groupPaymentProducts {
                    self.communicator.paymentProductGroups(forContext: context, success: { paymentProductGroups in
                        self.paymentProductGroups = paymentProductGroups
                        self.paymentProductGroups.stringFormatter = self.stringFormatter
                        // self.assetManager.initializeImages(for: paymentProductGroups.paymentProductGroups)
                        self.assetManager.updateImagesAsync(
                            for: paymentProductGroups.paymentProductGroups,
                            baseURL: self.communicator.assetsBaseURL
                        ) {
                            self.assetManager.initializeImages(for: paymentProductGroups.paymentProductGroups)
                            let items = PaymentItems(products: paymentProducts, groups: paymentProductGroups)
                            success(items)
                        }

                    }, failure: failure)
                } else {
                    let items = PaymentItems(products: paymentProducts, groups: nil)
                    success(items)
                }

            }

        }, failure: failure)
    }

    public func paymentProduct(
        withId paymentProductId: String,
        context: PaymentContext,
        success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        let key = "\(paymentProductId)-\(context.description)"

        if let paymentProduct = paymentProductMapping[key] as? PaymentProduct {
            success(paymentProduct)
        } else {
            communicator.paymentProduct(withIdentifier: paymentProductId, context: context, success: { paymentProduct in
                self.paymentProductMapping[key] = paymentProduct
                self.assetManager.initializeImages(for: paymentProduct)
                self.assetManager.updateImagesAsync(for: paymentProduct, baseURL: self.communicator.assetsBaseURL)

                success(paymentProduct)
            }, failure: { error in
                failure(error)
            })
        }
    }

    public func paymentProductGroup(withId paymentProductGroupId: String,
                                    context: PaymentContext,
                                    success: @escaping (_ paymentProductGroup: PaymentProductGroup) -> Void,
                                    failure: @escaping (_ error: Error) -> Void) {
        let key = "\(paymentProductGroupId)-\(context.description)"

        if let paymentProductGroup = paymentProductGroupMapping[key] as? PaymentProductGroup {
            success(paymentProductGroup)
        } else {
            communicator.paymentProductGroup(
                withIdentifier: paymentProductGroupId,
                context: context,
                success: { paymentProductGroup in
                    self.paymentProductGroupMapping[key] = paymentProductGroup
                    self.assetManager.initializeImages(for: paymentProductGroup)
                    self.assetManager.updateImagesAsync(
                        for: paymentProductGroup,
                        baseURL: self.communicator.assetsBaseURL
                    )
                    success(paymentProductGroup)
                },
                failure: { error in
                    failure(error)
                }
            )
        }
    }

    public func iinDetails(forPartialCreditCardNumber partialCreditCardNumber: String,
                           context: PaymentContext?,
                           success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
                           failure: @escaping (_ error: Error) -> Void) {
        if partialCreditCardNumber.count < 6 {
            let response = IINDetailsResponse(status: .notEnoughDigits)
            success(response)
        } else if self.iinLookupPending == true {
            let response = IINDetailsResponse(status: .pending)
            success(response)
        } else {
            iinLookupPending = true
            communicator.paymentProductId(
                byPartialCreditCardNumber: partialCreditCardNumber,
                context: context,
                success: { response in
                    self.iinLookupPending = false
                    success(response)
                },
                failure: { error in
                    self.iinLookupPending = false
                    failure(error)
                }
            )
        }
    }

    @available(*, deprecated, message: "Use convert(Int:String:Sring:) instead")
    public func convert(
        amountInCents: Int,
        source: CurrencyCode,
        target: CurrencyCode,
        success: @escaping (_ convertedAmountInCents: Int) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.convert(amountInCents: amountInCents, source: source, target: target, success: success, failure: failure)
    }

    public func convert(
        amountInCents: Int,
        source: String,
        target: String,
        success: @escaping (_ convertedAmountInCents: Int) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        communicator.convert(
            amountInCents: amountInCents,
            source: source,
            target: target,
            success: { convertedAmountInCents in
                success(convertedAmountInCents)
            },
            failure: { error in
                if let error = error {
                    failure(error)
                }
            }
        )
    }

    @available(*, deprecated, message: "Use directory(String:String:Sring:) instead")
    public func directory(
        forProductId paymentProductId: String,
        countryCode: CountryCode,
        currencyCode: CurrencyCode,
        success: @escaping (_ directory: DirectoryEntries) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        let key = "\(paymentProductId)-\(countryCode.rawValue)-\(currencyCode.rawValue)"

        if let directoryEntries = self.directoryEntriesMapping[key] as? DirectoryEntries {
            success(directoryEntries)
        } else {
            communicator.directory(
                forProduct: paymentProductId,
                countryCode: countryCode.rawValue,
                currencyCode: currencyCode.rawValue,
                success: { directoryEntries in
                    self.directoryEntriesMapping[key] = directoryEntries
                    success(directoryEntries)
                },
                failure: { error in
                    failure(error)
                }
            )
        }
    }

    public func directory(
        forProductId paymentProductId: String,
        countryCode: String,
        currencyCode: String,
        success: @escaping (_ directory: DirectoryEntries) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        let key = "\(paymentProductId)-\(countryCode)-\(currencyCode)"

        if let directoryEntries = self.directoryEntriesMapping[key] as? DirectoryEntries {
            success(directoryEntries)
        } else {
            communicator.directory(
                forProduct: paymentProductId,
                countryCode: countryCode,
                currencyCode: currencyCode,
                success: { directoryEntries in
                    self.directoryEntriesMapping[key] = directoryEntries
                    success(directoryEntries)
                },
                failure: { error in
                    failure(error)
                }
            )
        }
    }

    public func prepare(
        _ paymentRequest: PaymentRequest,
        success: @escaping (_ preparedPaymentRequest: PreparedPaymentRequest) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        communicator.publicKey(success: { publicKeyResponse in
            let publicKeyAsData = publicKeyResponse.encodedPublicKey.decode()
            guard let strippedPublicKeyAsData = self.encryptor.stripPublicKey(data: publicKeyAsData) else {
                failure(SessionError.RuntimeError("Failed to decode Public key."))
                return
            }
            let tag = "globalcollect-sdk-public-key-swift"

            self.encryptor.deleteRSAKey(withTag: tag)
            self.encryptor.storePublicKey(publicKey: strippedPublicKeyAsData, tag: tag)

            guard let publicKey = self.encryptor.RSAKey(withTag: tag) else {
                failure(SessionError.RuntimeError("Failed to find RSA Key."))
                return
            }

            let paymentRequestJSON =
                self.preparePaymentRequestJSON(forClientSessionId: self.clientSessionId, paymentRequest: paymentRequest)
            let encryptedFields =
                self.joseEncryptor.encryptToCompactSerialization(
                    JSON: paymentRequestJSON,
                    withPublicKey: publicKey,
                    keyId: publicKeyResponse.keyId
                )
            let encodedClientMetaInfo = self.communicator.base64EncodedClientMetaInfo
            let preparedRequest =
                PreparedPaymentRequest(encryptedFields: encryptedFields, encodedClientMetaInfo: encodedClientMetaInfo)
            success(preparedRequest)
        }, failure: { error in
            failure(error)
        })
    }

    private func preparePaymentRequestJSON(
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

    public var clientSessionId: String {
        return communicator.clientSessionId
    }

    @available(*, deprecated, message: "This function is dependant on Environment, and will therefore be removed.")
    public var isEnvironmentTypeProduction: Bool {
        return communicator.isEnvironmentTypeProduction
    }
    public func keyValuePairs(from dictionary: [String: String]) -> [[String: String]] {
        var keyValuePairs = [[String: String]]()
        for (key, value) in  dictionary {
            let pair = ["key": key, "value": value]
            keyValuePairs.append(pair)
        }
        return keyValuePairs
    }

    public func keyValueJSONFromDictionary(dictionary: [String: String]) -> String? {
        let keyValuePairs = self.keyValuePairs(from: dictionary)
        guard let JSONAsData = try? JSONSerialization.data(withJSONObject: keyValuePairs) else {
            Macros.DLog(message: "Unable to create JSON data from dictionary")
            return nil
        }

        return String(bytes: JSONAsData, encoding: String.Encoding.utf8)
    }
}
