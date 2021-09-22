//
//  C2SCommunicator.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import Alamofire
import PassKit

public class C2SCommunicator {
    public var configuration: C2SCommunicatorConfiguration
    public var networkingWrapper = AlamofireWrapper.shared
    
    public var baseURL: String {
        return configuration.baseURL
    }
    
    public var assetsBaseURL: String {
        return configuration.assetsBaseURL
    }
    
    public var clientSessionId: String {
        return configuration.clientSessionId
    }
    
    public var base64EncodedClientMetaInfo: String {
        return configuration.base64EncodedClientMetaInfo ?? ""
    }
    
    public var headers: NSDictionary {
        return [
            "Authorization" : "GCS v1Client:\(clientSessionId)",
            "X-GCS-ClientMetaInfo" : base64EncodedClientMetaInfo
        ]
    }

    @available(*, deprecated, message: "This function is dependant on Environment, and will therefore be removed.")
    public var isEnvironmentTypeProduction: Bool {
        return configuration.environment == .production ? true : false
    }
    
    
    public init(configuration: C2SCommunicatorConfiguration) {
        self.configuration = configuration
    }
    public func thirdPartyStatus(forPayment paymentId: String, success: @escaping (_ thirdPartyStatusResponse: ThirdPartyStatusResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let URL = "\(baseURL)/\(self.configuration.customerId)/payments/\(paymentId)/thirdpartystatus"
        
        getResponse(forURL: URL, withParameters: [:], success: { (responseObject) in
            guard let responseDic = responseObject as? [String : Any], let thirdPartyStatusResponse = ThirdPartyStatusResponse(json: responseDic) else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            
            success(thirdPartyStatusResponse)
        }) { error in
            failure(error)
        }
    }
    
    public func customerDetails(forProductId productId: String, withLookupValues lookupValues: [[String: String]], countryCode: CountryCode, success: @escaping (_ paymentProduct: CustomerDetails) ->  Void, failure: @escaping  (_ error: Error) -> Void )  {
        let URL = "\(baseURL)/\(configuration.customerId)/products/\(productId)/customerDetails"
        let params = ["values": lookupValues, "countryCode": countryCode.rawValue] as [String : Any]
        
        postResponse(forURL: URL, withParameters: params, additionalAcceptableStatusCodes: IndexSet([404, 400]), success: { (responseObject) in
            guard let responseDic = responseObject as? [String : Any], let customerDetails = CustomerDetails(json: responseDic), responseDic["errors"] == nil else {
                let errors = (responseObject as? [String: Any])?["errors"]
                if let errors = errors as? [[String: Any]] {
                    let customerDetailsError = CustomerDetailsError(responseValues: errors)
                    failure(customerDetailsError)
                    return
                }
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            success(customerDetails)
        }, failure: { error in
            failure(error)
        })

    }
    
    public func paymentProducts(forContext context: PaymentContext, success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let isRecurring = context.isRecurring ? "true" : "false"
        let URL = "\(baseURL)/\(configuration.customerId)/products"
        var params:[String:Any] = ["countryCode":context.countryCode.rawValue, "currencyCode":context.amountOfMoney.currencyCode.rawValue, "amount":context.amountOfMoney.totalAmount, "hide":"fields", "isRecurring":isRecurring]
        
        if let locale = context.locale {
            params["locale"] = locale
        }
        
        getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
            guard let responseDic = responseObject as? [String : Any] else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            var paymentProducts = BasicPaymentProducts(json: responseDic)
            paymentProducts = self.filterAndroidPayFromProducts(paymentProducts: paymentProducts)
            
            paymentProducts = self.checkApplePayAvailability(with: paymentProducts, for: context, success: {
                success(paymentProducts)
            }, failure: { error in
                failure(error)
            })
        }) { error in
            failure(error)
        }
    }
    
    public func filterAndroidPayFromProducts(paymentProducts: BasicPaymentProducts) -> BasicPaymentProducts {
        if let androidPayPaymentProduct = paymentProducts.paymentProduct(withIdentifier: SDKConstants.kAndroidPayIdentifier),
            let product = paymentProducts.paymentProducts.firstIndex(of: androidPayPaymentProduct) {
            paymentProducts.paymentProducts.remove(at: product)
        }
        
        return paymentProducts
    }
    
    public func checkApplePayAvailability(with paymentProducts: BasicPaymentProducts,
                                          for context: PaymentContext,
                                          success: @escaping () -> Void,
                                          failure: @escaping (_ error: Error) -> Void) -> BasicPaymentProducts {
        if let applePayPaymentProduct = paymentProducts.paymentProduct(withIdentifier: SDKConstants.kApplePayIdentifier) {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") && PKPaymentAuthorizationViewController.canMakePayments() {
                
                paymentProductNetworks(forProduct: SDKConstants.kApplePayIdentifier, context: context, success: {(_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                    if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct),
                        !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentProductNetworks.paymentProductNetworks) {
                        paymentProducts.paymentProducts.remove(at: product)
                    }
                    success()
                }, failure: { error in
                    failure(error)
                })
            } else {
                if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct) {
                    paymentProducts.paymentProducts.remove(at: product)
                }
                
                success()
            }
        } else {
            success()
        }
        
        return paymentProducts
    }
    
    public func paymentProductNetworks(forProduct paymentProductId: String,
                                       context: PaymentContext,
                                       success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void,
                                       failure: @escaping (_ error: Error) -> Void) {
        let isRecurring = context.isRecurring ? "true" : "false"
        guard let locale = context.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }
        let URL = "\(self.baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/networks"
        let params:[String:Any] = ["countryCode":context.countryCode.rawValue, "locale":locale, "currencyCode":context.amountOfMoney.currencyCode.rawValue, "amount":context.amountOfMoney.totalAmount, "hide":"fields", "isRecurring":isRecurring]
        
        getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
            guard let response = responseObject as? [String: Any] else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            let rawProductNetworks = response["networks"]
            let paymentProductNetworks = PaymentProductNetworks()
            if let productNetworks = rawProductNetworks as? [PKPaymentNetwork] {
                paymentProductNetworks.paymentProductNetworks.append(contentsOf: productNetworks)
            }
            success(paymentProductNetworks)
        }) { error in
            failure(error)
        }
    }
    
    public func paymentProductGroups(forContext context: PaymentContext, success: @escaping (_ paymentProductGroups: BasicPaymentProductGroups) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let isRecurring = context.isRecurring ? "true" : "false"
        guard let locale = context.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }
        
        let URL = "\(baseURL)/\(configuration.customerId)/productgroups"
        let params:[String:Any] = ["countryCode":context.countryCode.rawValue, "locale":locale, "currencyCode":context.amountOfMoney.currencyCode.rawValue, "amount":context.amountOfMoney.totalAmount, "hide":"fields", "isRecurring":isRecurring]
        
        getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
            guard let responseDic = responseObject as? [String : Any] else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            let paymentProductGroups = BasicPaymentProductGroups(json: responseDic)
            success(paymentProductGroups)
        }) { error in
            failure(error)
        }
    }
    
    public func paymentProduct(withIdentifier paymentProductId: String,
                               context: PaymentContext,
                               success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
                               failure: @escaping (_ error: Error) -> Void) {

        checkAvailability(forProduct: paymentProductId, context: context, success: {() -> Void in
            let isRecurring = context.isRecurring ? "true" : "false"
            
            let URL = "\(self.baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/"
            var params:[String:Any] = ["countryCode":context.countryCode.rawValue, "currencyCode":context.amountOfMoney.currencyCode.rawValue, "amount":context.amountOfMoney.totalAmount, "isRecurring":isRecurring]
            if let forceBasicFlow = context.forceBasicFlow {
                params["forceBasicFlow"] = forceBasicFlow ? "true" : "false"
            }
            if let locale = context.locale {
                params["locale"] = locale
            }

            self.getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
                guard let responseDic = responseObject as? [String : Any], let paymentProduct = PaymentProduct(json: responseDic) else {
                    failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                    return
                }
                success(paymentProduct)
            }, failure: { error in
                failure(error)
            })
        }, failure: { error in
            failure(error)
        })
    }
    
    public func checkAvailability(forProduct paymentProductId: String, context: PaymentContext, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        if paymentProductId == SDKConstants.kApplePayIdentifier {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") && PKPaymentAuthorizationViewController.canMakePayments() {
                paymentProductNetworks(forProduct: SDKConstants.kApplePayIdentifier, context: context, success: {(_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                    if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentProductNetworks.paymentProductNetworks) {
                        failure(self.badRequestError(forProduct: paymentProductId, context: context))
                    }
                    else {
                        success()
                    }
                }, failure: { error in
                    failure(error)
                })
            }
            else {
                failure(badRequestError(forProduct: paymentProductId, context: context))
            }
        }
        else {
            success()
        }
    }
    
    public func badRequestError(forProduct paymentProductId: String, context: PaymentContext) -> Error {
        let isRecurring = context.isRecurring ? "true" : "false"
        let url = "\(baseURL)/\(configuration.customerId)/products/\(paymentProductId)/?countryCode=\(context.countryCode.rawValue)&locale=\(context.locale!)&currencyCode=\(context.amountOfMoney.currencyCode.rawValue)&amount=\(UInt(context.amountOfMoney.totalAmount))&isRecurring=\(isRecurring)"
        let errorUserInfo = ["com.alamofire.serialization.response.error.response":
            HTTPURLResponse(url: URL(string: url)!, statusCode: 400, httpVersion: nil, headerFields: ["Connection": "close"])!, "NSErrorFailingURLKey": url, "com.alamofire.serialization.response.error.data": Data(), "NSLocalizedDescription": "Request failed: bad request (400)"] as [String : Any]
        let error = NSError(domain: "com.alamofire.serialization.response.error.response", code: -1011, userInfo: errorUserInfo)
        return error
    }
    
    public func paymentProductGroup(withIdentifier paymentProductGroupId: String,
                                    context: PaymentContext,
                                    success: @escaping (_ paymentProductGroup: PaymentProductGroup) -> Void,
                                    failure: @escaping (_ error: Error) -> Void) {
        let isRecurring = context.isRecurring ? "true" : "false"
        
        guard let locale = context.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }
        
        let URL = "\(baseURL)/\(configuration.customerId)/productgroups/\(paymentProductGroupId)/"
        let params:[String:Any] = ["countryCode":context.countryCode.rawValue, "locale":locale, "currencyCode":context.amountOfMoney.currencyCode.rawValue, "amount":context.amountOfMoney.totalAmount, "isRecurring":isRecurring]
        
        self.getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
            guard let responseDic = responseObject as? [String : Any], let paymentProductGroup = PaymentProductGroup(json: responseDic) else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            success(paymentProductGroup)
        }, failure: { error in
            failure(error)
        })
    }
    
    public func publicKey(success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let URL = "\(baseURL)/\(configuration.customerId)/crypto/publickey"
        getResponse(forURL: URL, success: {(_ responseObject: Any) -> Void in
            guard let rawPublicKeyResponse = responseObject as? [AnyHashable: Any],
                let keyId = rawPublicKeyResponse["keyId"] as? String,
                let encodedPublicKey = rawPublicKeyResponse["publicKey"] as? String else {
                failure(SessionError.RuntimeError("Response was invalid. Raw response: \(responseObject)"))
                return
            }
            let response = PublicKeyResponse(keyId: keyId , encodedPublicKey: encodedPublicKey)
            success(response)
        }, failure: { error in
            failure(error)
        })
    }
    
    public func paymentProductId(byPartialCreditCardNumber partialCreditCardNumber: String,
                                 context: PaymentContext?,
                                 success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
                                 failure: @escaping (_ error: Error) -> Void) {
        let URL = "\(baseURL)/\(configuration.customerId)/services/getIINdetails"

        var parameters: [String: Any] = [:]
        parameters["bin"] = getIINDigitsFrom(partialCreditCardNumber: partialCreditCardNumber)

        if let context = context {
            var paymentContext: [String: Any] = [:]
            paymentContext["isRecurring"] = context.isRecurring ? "true" : "false"
            paymentContext["countryCode"] = context.countryCode.rawValue
            
            var amountOfMoney: [String: Any] = [:]
            amountOfMoney["amount"] = String(context.amountOfMoney.totalAmount)
            amountOfMoney["currencyCode"] = context.amountOfMoney.currencyCode.rawValue
            paymentContext["amountOfMoney"] = amountOfMoney
            
            parameters["paymentContext"] = paymentContext
        }
        
        let additionalAcceptableStatusCodes = IndexSet(integer: 404)
        postResponse(forURL: URL, withParameters: parameters, additionalAcceptableStatusCodes: additionalAcceptableStatusCodes, success: {(responseObject) -> Void in
            guard let json = responseObject as? [String: Any] else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            let response = IINDetailsResponse(json: json)
            success(response)
        }, failure: { error in
            failure(error)
        })
    }

    func getIINDigitsFrom(partialCreditCardNumber: String) -> String {
        let max: Int
        if partialCreditCardNumber.count >= 8 {
            max = 8
        } else {
            max = min(partialCreditCardNumber.count, 6)
        }
        return String(partialCreditCardNumber[..<partialCreditCardNumber.index(partialCreditCardNumber.startIndex, offsetBy: max)])
    }
    
    public func convert(amountInCents: Int, source: CurrencyCode, target: CurrencyCode, success: @escaping (_ convertedAmountInCents: Int) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        let amount = "\(amountInCents)"
        let URL = "\(baseURL)/\(configuration.customerId)/services/convert/amount"
        let params:[String:Any] = ["source":source.rawValue, "target":target.rawValue, "amount":amount]
        
        getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
            guard let json = responseObject as? [String: Any] else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            if let input = json["convertedAmount"] as? Int {
                success(input)
            } else {
                failure(nil)
            }
        }) { error in
            failure(error)
        }
    }
    
    public func directory(forProduct paymentProductId: String, countryCode: CountryCode, currencyCode: CurrencyCode, success: @escaping (_ directoryEntries: DirectoryEntries) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let URL = "\(baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/directory"
        let params:[String:Any] = ["countryCode":countryCode.rawValue, "currencyCode":currencyCode.rawValue]
        
        getResponse(forURL: URL, withParameters: params, success: { (responseObject) in
            guard let responseDic = responseObject as? [String : Any] else {
                failure(SessionError.RuntimeError("Response was not a dictionary. Raw response: \(responseObject)"))
                return
            }
            let directoryEntries = DirectoryEntries(json: responseDic)
            success(directoryEntries)
        }) { error in
            failure(error)
        }
    }
    
    public func getResponse(forURL URL: String, withParameters parameters:Parameters? = nil, success: @escaping (_ responseObject: Any) -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        var httpHeaders: [HTTPHeader] = []
        headers.forEach{
            if let key = $0.key as? String, let value = $0.value as? String {
                httpHeaders.append(HTTPHeader(name: key, value: value))
            }
        }
        
        networkingWrapper.getResponse(forURL: URL, withParameters: parameters, headers: HTTPHeaders(httpHeaders), additionalAcceptableStatusCodes: nil, success: success, failure: failure)
    }
    
    public func postResponse(forURL URL: String, withParameters parameters: [AnyHashable: Any], additionalAcceptableStatusCodes: IndexSet, success: @escaping (_ responseObject: Any) -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        var httpHeaders: [HTTPHeader] = []
        headers.forEach{
            if let key = $0.key as? String, let value = $0.value as? String {
                httpHeaders.append(HTTPHeader(name: key, value: value))
            }
        }
        
        networkingWrapper.postResponse(forURL: URL, headers: HTTPHeaders(httpHeaders), withParameters: parameters as? Parameters, additionalAcceptableStatusCodes: additionalAcceptableStatusCodes, success: success, failure: failure)
    }
    
}
