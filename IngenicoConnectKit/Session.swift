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
    
    public var iinLookupPending = false
    
    public init(communicator: C2SCommunicator, assetManager: AssetManager, encryptor: Encryptor, JOSEEncryptor: JOSEEncryptor, stringFormatter: StringFormatter) {
        self.communicator = communicator
        self.assetManager = assetManager
        self.encryptor = encryptor
        self.joseEncryptor = JOSEEncryptor
        self.stringFormatter = stringFormatter
    }
    
    public convenience init(clientSessionId: String, customerId: String, region: Region, environment: Environment, appIdentifier: String) {
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
        
        self.init(communicator: communicator, assetManager: assetManager, encryptor: encryptor, JOSEEncryptor: jsonEncryptor, stringFormatter: stringFormatter)
    }
    
    public func paymentProducts(for context: PaymentContext, success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProducts(forContext: context, success: { paymentProducts in
            self.paymentProducts = paymentProducts
            self.paymentProducts.stringFormatter = self.stringFormatter
            self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
            self.assetManager.updateImagesAsync(for: paymentProducts.paymentProducts, baseURL: self.communicator.assetsBaseURL) {
                success(paymentProducts)
            }
            
        }, failure: { error in
            failure(error)
        })
    }
    
    public func paymentProductNetworks(forProductId paymentProductId: String, context: PaymentContext, success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProductNetworks(forProduct: paymentProductId, context: context, success: { paymentProductNetworks in
            success(paymentProductNetworks)
        }, failure: { error in
            failure(error)
        })
    }
    
    public func paymentProductGroups(for context: PaymentContext, success: @escaping (_ paymentProductGroups: BasicPaymentProductGroups) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProductGroups(forContext: context, success: { paymentProductGroups in
            self.paymentProductGroups = paymentProductGroups
            self.paymentProductGroups.stringFormatter = self.stringFormatter
            self.assetManager.initializeImages(for: paymentProductGroups.paymentProductGroups)
            self.assetManager.updateImagesAsync(for: paymentProductGroups.paymentProductGroups, baseURL: self.communicator.assetsBaseURL)
            
            success(paymentProductGroups)
        }, failure: { error in
            failure(error)
        })
    }
    
    public func paymentItems(for context: PaymentContext, groupPaymentProducts: Bool, success: @escaping (_ paymentItems: PaymentItems) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.paymentProducts(forContext: context, success: { paymentProducts in
            self.paymentProducts = paymentProducts
            self.paymentProducts.stringFormatter = self.stringFormatter
            //self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
            self.assetManager.updateImagesAsync(for: paymentProducts.paymentProducts, baseURL: self.communicator.assetsBaseURL) {
                self.assetManager.initializeImages(for: paymentProducts.paymentProducts)
                if groupPaymentProducts {
                    self.communicator.paymentProductGroups(forContext: context, success: { paymentProductGroups in
                        self.paymentProductGroups = paymentProductGroups
                        self.paymentProductGroups.stringFormatter = self.stringFormatter
                        //self.assetManager.initializeImages(for: paymentProductGroups.paymentProductGroups)
                        self.assetManager.updateImagesAsync(for: paymentProductGroups.paymentProductGroups, baseURL: self.communicator.assetsBaseURL) {
                            self.assetManager.initializeImages(for: paymentProductGroups.paymentProductGroups)
                            let items = PaymentItems(products: paymentProducts, groups: paymentProductGroups)
                            success(items)
                        }
                        
                    }, failure: failure)
                }
                else {
                    let items = PaymentItems(products: paymentProducts, groups: nil)
                    success(items)
                }

            }
            
        }, failure: failure)
    }
    
    public func paymentProduct(withId paymentProductId: String, context: PaymentContext, success: @escaping (_ paymentProduct: PaymentProduct) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let key = "\(paymentProductId)-\(context.description)"
        
        if let paymentProduct = paymentProductMapping[key] as? PaymentProduct {
            success(paymentProduct)
        }
        else {
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
        }
        else {
            communicator.paymentProductGroup(withIdentifier: paymentProductGroupId, context: context, success: { paymentProductGroup in
                self.paymentProductGroupMapping[key] = paymentProductGroup
                self.assetManager.initializeImages(for: paymentProductGroup)
                self.assetManager.updateImagesAsync(for: paymentProductGroup, baseURL: self.communicator.assetsBaseURL)
                success(paymentProductGroup)
            }, failure: { error in
                failure(error)
            })
        }
    }
    
    public func iinDetails(forPartialCreditCardNumber partialCreditCardNumber: String,
                           context: PaymentContext?,
                           success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
                           failure: @escaping (_ error: Error) -> Void) {
        if partialCreditCardNumber.length < 6 {
            let response = IINDetailsResponse(status: .notEnoughDigits)
            success(response)
        }
        else if self.iinLookupPending == true {
            let response = IINDetailsResponse(status: .pending)
            success(response)
        }
        else {
            iinLookupPending = true
            communicator.paymentProductId(byPartialCreditCardNumber: partialCreditCardNumber, context: context, success: { response in
                self.iinLookupPending = false
                success(response)
            }, failure: { error in
                self.iinLookupPending = false
                failure(error)
            })
        }
        
    }
    
    public func convert(amountInCents: Int, source: CurrencyCode, target: CurrencyCode, success: @escaping (_ convertedAmountInCents: Int) -> Void, failure: @escaping (_ error: Error) -> Void) {
        communicator.convert(amountInCents: amountInCents, source: source, target: target, success: { convertedAmountInCents in
            success(convertedAmountInCents)
        }, failure: { error in
            if let error = error {
                failure(error)
            }
        })
    }
    
    public func directory(forProductId paymentProductId: String, countryCode: CountryCode, currencyCode: CurrencyCode, success: @escaping (_ directory: DirectoryEntries) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let key = "\(paymentProductId)-\(countryCode)-\(currencyCode)"
        
        if let directoryEntries = self.directoryEntriesMapping[key] as? DirectoryEntries {
            success(directoryEntries)
        }
        else {
            communicator.directory(forProduct: paymentProductId, countryCode: countryCode, currencyCode: currencyCode, success: { directoryEntries in
                self.directoryEntriesMapping[key] = directoryEntries
                success(directoryEntries)
            }, failure: { error in
                failure(error)
            })
        }
    }
    
    public func prepare(_ paymentRequest: PaymentRequest, success: @escaping (_ preparedPaymentRequest: PreparedPaymentRequest) -> Void, failure: @escaping (_ error: Error) -> Void) {
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
            
            let paymentRequestJSON = self.preparePaymentRequestJSON(forClientSessionId: self.clientSessionId, paymentRequest: paymentRequest)
            let encryptedFields = self.joseEncryptor.encryptToCompactSerialization(JSON: paymentRequestJSON, withPublicKey: publicKey, keyId: publicKeyResponse.keyId)
            let encodedClientMetaInfo = self.communicator.base64EncodedClientMetaInfo
            let preparedRequest = PreparedPaymentRequest(encryptedFields: encryptedFields, encodedClientMetaInfo: encodedClientMetaInfo)
            
            success(preparedRequest)
        }, failure: { error in
            failure(error)
        })
    }
    
    private func preparePaymentRequestJSON(forClientSessionId clientSessionId: String, paymentRequest: PaymentRequest) -> String {
        var paymentRequestJSON = String()
        
        guard let paymentProduct = paymentRequest.paymentProduct else {
            NSException(name: NSExceptionName(rawValue: "Invalid payment product"), reason: "Payment product is invalid").raise()
            //Return is mandatory but will never be reached because of the exception above.
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
        if let fieldVals = paymentRequest.unmaskedFieldValues, let values = self.keyValueJSONFromDictionary(dictionary: fieldVals) {
            let paymentValues = "\"paymentValues\": \(values)}"
            paymentRequestJSON += paymentValues
        }
        
        return paymentRequestJSON
    }
    
    public var clientSessionId: String {
        return communicator.clientSessionId
    }
    
    public var isEnvironmentTypeProduction: Bool {
        return communicator.isEnvironmentTypeProduction
    }

    public func keyValueJSONFromDictionary(dictionary: [String:String]) -> String? {
        guard let JSONAsData = try? JSONSerialization.data(withJSONObject: dictionary) else {
            Macros.DLog(message: "Unable to create JSON data from dictionary")
            return nil
        }

        return String(bytes: JSONAsData, encoding: String.Encoding.utf8)
    }
}
