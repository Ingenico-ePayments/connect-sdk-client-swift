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

@available(
    *,
    deprecated,
    message:
        """
        In a future release, this class, its functions and its properties will become internal to the SDK.
        Please use Session to interact with the API.
        """
)
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

    internal var loggingEnabled: Bool {
        return configuration.loggingEnabled
    }

    @available(*, deprecated, message: "In a future release, this property will be removed.")
    public var headers: NSDictionary {
        return [
            "Authorization": "GCS v1Client:\(clientSessionId)",
            "X-GCS-ClientMetaInfo": base64EncodedClientMetaInfo
        ]
    }

    private var httpHeaders: HTTPHeaders {
        return [
            "Authorization": "GCS v1Client:\(clientSessionId)",
            "X-GCS-ClientMetaInfo": base64EncodedClientMetaInfo
        ]
    }

    @available(*, deprecated, message: "This function is dependant on Environment, and will therefore be removed.")
    public var isEnvironmentTypeProduction: Bool {
        return configuration.environment == .production ? true : false
    }

    public init(configuration: C2SCommunicatorConfiguration) {
        self.configuration = configuration
    }

    public func thirdPartyStatus(
        forPayment paymentId: String,
        success: @escaping (_ thirdPartyStatusResponse: ThirdPartyStatusResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let URL = "\(baseURL)/\(self.configuration.customerId)/payments/\(paymentId)/thirdpartystatus"

        getResponse(
            forURL: URL,
            withParameters: [:],
            success: { (responseObject: ThirdPartyStatusResponse?) in
                guard let thirdPartyStatusResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(thirdPartyStatusResponse)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    public func paymentProducts(
        forContext context: PaymentContext,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let isRecurring = context.isRecurring ? "true" : "false"
        let URL = "\(baseURL)/\(configuration.customerId)/products"
        var params: [String: Any] =
            [
                "countryCode": context.countryCodeString,
                "currencyCode": context.amountOfMoney.currencyCodeString,
                "amount": context.amountOfMoney.totalAmount,
                "hide": "fields",
                "isRecurring": isRecurring
            ]

        if let locale = context.locale {
            params["locale"] = locale
        }

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: BasicPaymentProducts?) in
                guard var paymentProductsResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                paymentProductsResponse = self.checkApplePayAvailability(
                    with: paymentProductsResponse,
                    for: context,
                    success: {
                        success(paymentProductsResponse)
                    },
                    failure: { error in
                        failure(error)
                    },
                    apiFailure: { errorResponse in
                        apiFailure?(errorResponse)
                    }
                )
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    @available(
        *,
        deprecated,
        message:
            """
            In a future release, this function will be removed since GooglePay can also be used on iOS.
            """
    )
    public func filterAndroidPayFromProducts(paymentProducts: BasicPaymentProducts) -> BasicPaymentProducts {
        if let androidPayPaymentProduct =
            paymentProducts.paymentProduct(withIdentifier: SDKConstants.kAndroidPayIdentifier),
            let product = paymentProducts.paymentProducts.firstIndex(of: androidPayPaymentProduct) {
            paymentProducts.paymentProducts.remove(at: product)
        }

        return paymentProducts
    }

    public func checkApplePayAvailability(with paymentProducts: BasicPaymentProducts,
                                          for context: PaymentContext,
                                          success: @escaping () -> Void,
                                          failure: @escaping (_ error: Error) -> Void,
                                          apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) -> BasicPaymentProducts {
        if let applePayPaymentProduct =
            paymentProducts.paymentProduct(withIdentifier: SDKConstants.kApplePayIdentifier) {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") &&
                PKPaymentAuthorizationViewController.canMakePayments() {
                paymentProductNetworks(
                    forProduct: SDKConstants.kApplePayIdentifier,
                    context: context,
                    success: { (_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                        if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct),
                            !PKPaymentAuthorizationViewController.canMakePayments(
                                usingNetworks: paymentProductNetworks.paymentProductNetworks
                            ) {
                            paymentProducts.paymentProducts.remove(at: product)
                        }
                        success()
                    },
                    failure: { error in
                        failure(error)
                    },
                    apiFailure: { errorResponse in
                        apiFailure?(errorResponse)
                    }
                )
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
                                       failure: @escaping (_ error: Error) -> Void,
                                       apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let isRecurring = context.isRecurring ? "true" : "false"
        guard let locale = context.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }
        let URL = "\(self.baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/networks"
        let params: [String: Any] =
            [
                "countryCode": context.countryCodeString,
                "locale": locale,
                "currencyCode": context.amountOfMoney.currencyCodeString,
                "amount": context.amountOfMoney.totalAmount,
                "hide": "fields",
                "isRecurring": isRecurring
            ]

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: PaymentProductNetworks?) in
                guard let paymentProductNetworks = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(paymentProductNetworks)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    public func paymentProductGroups(
        forContext context: PaymentContext,
        success: @escaping (_ paymentProductGroups: BasicPaymentProductGroups) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let isRecurring = context.isRecurring ? "true" : "false"
        guard let locale = context.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }

        let URL = "\(baseURL)/\(configuration.customerId)/productgroups"
        let params: [String: Any] =
            [
                "countryCode": context.countryCodeString,
                "locale": locale,
                "currencyCode": context.amountOfMoney.currencyCodeString,
                "amount": context.amountOfMoney.totalAmount,
                "hide": "fields",
                "isRecurring": isRecurring
            ]

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: BasicPaymentProductGroups?) in
                guard let paymentProductGroups = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(paymentProductGroups)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    public func paymentProduct(withIdentifier paymentProductId: String,
                               context: PaymentContext,
                               success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
                               failure: @escaping (_ error: Error) -> Void,
                               apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        checkAvailability(
            forProduct: paymentProductId,
            context: context,
            success: {() -> Void in
                let isRecurring = context.isRecurring ? "true" : "false"

                let URL = "\(self.baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/"
                var params: [String: Any] =
                [
                    "countryCode": context.countryCodeString,
                    "currencyCode": context.amountOfMoney.currencyCodeString,
                    "amount": context.amountOfMoney.totalAmount,
                    "isRecurring": isRecurring
                ]
                if let forceBasicFlow = context.forceBasicFlow {
                    params["forceBasicFlow"] = forceBasicFlow ? "true" : "false"
                }
                if let locale = context.locale {
                    params["locale"] = locale
                }

                self.getResponse(
                    forURL: URL,
                    withParameters: params,
                    success: { (responseObject: PaymentProduct?) in
                        guard let paymentProduct = responseObject else {
                            failure(SessionError.RuntimeError("Response was empty."))
                            return
                        }

                        success(paymentProduct)
                    }, failure: { error in
                        failure(error)
                    }, apiFailure: {errorResponse in
                        apiFailure?(errorResponse)
                    }
                )
            },
            failure: { error in
                failure(error)
            },
            apiFailure: {errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    public func checkAvailability(
        forProduct paymentProductId: String,
        context: PaymentContext,
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        if paymentProductId == SDKConstants.kApplePayIdentifier {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") &&
                PKPaymentAuthorizationViewController.canMakePayments() {
                paymentProductNetworks(
                    forProduct: SDKConstants.kApplePayIdentifier,
                    context: context,
                    success: { (_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                        if !PKPaymentAuthorizationViewController.canMakePayments(
                            usingNetworks: paymentProductNetworks.paymentProductNetworks
                        ) {
                            failure(self.badRequestError(forProduct: paymentProductId, context: context))
                        } else {
                            success()
                        }
                    },
                    failure: { error in
                        failure(error)
                    },
                    apiFailure: { errorResponse in
                        apiFailure?(errorResponse)
                    }
                )
            } else {
                failure(badRequestError(forProduct: paymentProductId, context: context))
            }
        } else {
            success()
        }
    }

    public func badRequestError(forProduct paymentProductId: String, context: PaymentContext) -> Error {
        let url = createBadRequestErrorURL(forProduct: paymentProductId, context: context)
        let errorUserInfo =
            [
                "com.alamofire.serialization.response.error.response":
                HTTPURLResponse(
                    url: URL(string: url)!,
                    statusCode: 400,
                    httpVersion: nil,
                    headerFields: ["Connection": "close"]
                )!,
                "NSErrorFailingURLKey": url,
                "com.alamofire.serialization.response.error.data": Data(),
                "NSLocalizedDescription": "Request failed: bad request (400)"
            ] as [String: Any]
        let error =
            NSError(
                domain: "com.alamofire.serialization.response.error.response",
                code: -1011,
                userInfo: errorUserInfo
            )
        return error
    }

    private func createBadRequestErrorURL(forProduct paymentProductId: String, context: PaymentContext) -> String {
        let isRecurring = context.isRecurring ? "true" : "false"
        // swiftlint:disable line_length
        return
            "\(baseURL)/\(configuration.customerId)/products/\(paymentProductId)/?countryCode=\(context.countryCodeString)&locale=\(context.locale!)&currencyCode=\(context.amountOfMoney.currencyCodeString)&amount=\(UInt(context.amountOfMoney.totalAmount))&isRecurring=\(isRecurring)"
        // swiftlint:enable line_length
    }

    public func paymentProductGroup(withIdentifier paymentProductGroupId: String,
                                    context: PaymentContext,
                                    success: @escaping (_ paymentProductGroup: PaymentProductGroup) -> Void,
                                    failure: @escaping (_ error: Error) -> Void,
                                    apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let isRecurring = context.isRecurring ? "true" : "false"

        guard let locale = context.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }

        let URL = "\(baseURL)/\(configuration.customerId)/productgroups/\(paymentProductGroupId)/"
        let params: [String: Any] =
            [
                "countryCode": context.countryCodeString,
                 "locale": locale,
                 "currencyCode": context.amountOfMoney.currencyCodeString,
                 "amount": context.amountOfMoney.totalAmount,
                 "isRecurring": isRecurring
            ]

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: PaymentProductGroup?) in
                guard let paymentProductGroup = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(paymentProductGroup)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    public func publicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let URL = "\(baseURL)/\(configuration.customerId)/crypto/publickey"

        getResponse(
            forURL: URL,
            success: { (responseObject: PublicKeyResponse?) -> Void in
                guard let publicKeyResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(publicKeyResponse)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    public func paymentProductId(byPartialCreditCardNumber partialCreditCardNumber: String,
                                 context: PaymentContext?,
                                 success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
                                 failure: @escaping (_ error: Error) -> Void,
                                 apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let URL = "\(baseURL)/\(configuration.customerId)/services/getIINdetails"

        var parameters: [String: Any] = [:]
        parameters["bin"] = getIINDigitsFrom(partialCreditCardNumber: partialCreditCardNumber)

        if let context = context {
            var paymentContext: [String: Any] = [:]
            paymentContext["isRecurring"] = context.isRecurring ? "true" : "false"
            paymentContext["countryCode"] = context.countryCodeString

            var amountOfMoney: [String: Any] = [:]
            amountOfMoney["amount"] = String(context.amountOfMoney.totalAmount)
            amountOfMoney["currencyCode"] = context.amountOfMoney.currencyCodeString
            paymentContext["amountOfMoney"] = amountOfMoney

            parameters["paymentContext"] = paymentContext
        }

        let additionalAcceptableStatusCodes = IndexSet(integer: 404)
        postResponse(
            forURL: URL,
            withParameters: parameters,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: { (responseObject: IINDetailsResponse?) -> Void in
                guard let iinDetailsResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(iinDetailsResponse)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    func getIINDigitsFrom(partialCreditCardNumber: String) -> String {
        let max: Int
        if partialCreditCardNumber.count >= 8 {
            max = 8
        } else {
            max = min(partialCreditCardNumber.count, 6)
        }
        return
            String(
                partialCreditCardNumber[
                    ..<partialCreditCardNumber.index(partialCreditCardNumber.startIndex, offsetBy: max)
                ]
            )
    }

    public func convert(
        amountInCents: Int,
        source: String,
        target: String,
        success: @escaping (_ convertedAmountInCents: Int) -> Void,
        failure: @escaping (_ error: Error?) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let amount = "\(amountInCents)"
        let URL = "\(baseURL)/\(configuration.customerId)/services/convert/amount"
        let params: [String: Any] = ["source": source, "target": target, "amount": amount]

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: ConvertedAmountResponse?) in
                guard let convertedAmountResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(convertedAmountResponse.convertedAmount)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    internal func convert(
        amountInCents: Int,
        source: String,
        target: String,
        success: @escaping (_ convertedAmountResponse: ConvertedAmountResponse) -> Void,
        failure: @escaping (_ error: Error?) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let amount = "\(amountInCents)"
        let URL = "\(baseURL)/\(configuration.customerId)/services/convert/amount"
        let params: [String: Any] = ["source": source, "target": target, "amount": amount]

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: ConvertedAmountResponse?) in
                guard let convertedAmountResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(convertedAmountResponse)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    public func directory(
        forProduct paymentProductId: String,
        countryCode: String,
        currencyCode: String,
        success: @escaping (_ directoryEntries: DirectoryEntries) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        let URL = "\(baseURL)/\(self.configuration.customerId)/products/\(paymentProductId)/directory"
        let params: [String: Any] = ["countryCode": countryCode, "currencyCode": currencyCode]

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: DirectoryEntries?) in
                guard let directoryEntries = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(directoryEntries)
            },
            failure: { error in
                failure(error)
            },
            apiFailure: { errorResponse in
                apiFailure?(errorResponse)
            }
        )
    }

    @available(*, deprecated, message: "In a future release, this function will be removed.")
    public func getResponse(
        forURL URL: String,
        withParameters parameters: Parameters? = nil,
        success: @escaping (_ responseObject: Any) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        if loggingEnabled {
            logRequest(forURL: URL, requestMethod: .get)
        }

        networkingWrapper.getResponse(
            forURL: URL,
            withParameters: parameters,
            headers: httpHeaders,
            additionalAcceptableStatusCodes: nil,
            success: { response in
                if self.loggingEnabled {
                    self.logSuccessResponse(forURL: URL, forResponse: response)
                }
                success(response as Any)
            },
            failure: { error in
                if self.loggingEnabled {
                    self.logFailureResponse(forURL: URL, forError: error)
                }
                failure(error)
            }
        )
    }

    private func getResponse<T: Codable>(
        forURL URL: String,
        withParameters parameters: Parameters? = nil,
        success: @escaping (_ responseObject: T?) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        if loggingEnabled {
            logRequest(forURL: URL, requestMethod: .get)
        }

        let successHandler: (T?, Int?) -> Void = { (responseObject, statusCode) -> Void in
               if self.loggingEnabled {
                   self.logSuccessResponse(forURL: URL, withResponseCode: statusCode, forResponse: responseObject)
               }
               success(responseObject)
        }

        networkingWrapper.getResponse(
            forURL: URL,
            headers: httpHeaders,
            withParameters: parameters,
            additionalAcceptableStatusCodes: nil,
            success: successHandler,
            failure: { error in
                if self.loggingEnabled {
                    self.logFailureResponse(forURL: URL, forError: error)
                }
                failure(error)
            },
            apiFailure: { errorResponse in
                if self.loggingEnabled {
                    self.logApiFailureResponse(forURL: URL, forApiError: errorResponse)
                }
                apiFailure?(errorResponse)
            }
        )
    }

    @available(*, deprecated, message: "In a future release, this function will be removed.")
    public func postResponse(
        forURL URL: String,
        withParameters parameters: [AnyHashable: Any],
        additionalAcceptableStatusCodes: IndexSet,
        success: @escaping (_ responseObject: Any) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        if loggingEnabled {
            logRequest(forURL: URL, requestMethod: .post, postBody: parameters as? Parameters)
        }

        networkingWrapper.postResponse(
            forURL: URL,
            headers: httpHeaders,
            withParameters: parameters as? Parameters,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: { response in
                if self.loggingEnabled {
                    self.logSuccessResponse(forURL: URL, forResponse: response)
                }
                success(response as Any)
            },
            failure: { error in
                if self.loggingEnabled {
                    self.logFailureResponse(forURL: URL, forError: error)
                }
                failure(error)
            }
        )
    }

    private func postResponse<T: Codable>(
        forURL URL: String,
        withParameters parameters: [AnyHashable: Any],
        additionalAcceptableStatusCodes: IndexSet?,
        success: @escaping (_ responseObject: T?) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: ((_ errorResponse: ApiErrorResponse) -> Void)? = nil
    ) {
        if loggingEnabled {
            logRequest(forURL: URL, requestMethod: .post, postBody: parameters as? Parameters)
        }

        let successHandler: (T?, Int?) -> Void = { (responseObject, statusCode) -> Void in
               if self.loggingEnabled {
                   self.logSuccessResponse(forURL: URL, withResponseCode: statusCode, forResponse: responseObject)
               }
               success(responseObject)
        }

        networkingWrapper.postResponse(
            forURL: URL,
            headers: httpHeaders,
            withParameters: parameters as? Parameters,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: successHandler,
            failure: { error in
                if self.loggingEnabled {
                    self.logFailureResponse(forURL: URL, forError: error)
                }
                failure(error)
            },
            apiFailure: { errorResponse in
                if self.loggingEnabled {
                    self.logApiFailureResponse(forURL: URL, forApiError: errorResponse)
                }
                apiFailure?(errorResponse)
            }
        )
    }

    private func responseWithoutStatusCode(response: [String: Any]?) -> [String: Any]? {
        var originalResponse = response
        originalResponse?.removeValue(forKey: "statusCode")

        return originalResponse
    }

    @available(
        *,
        deprecated,
        message:
            """
            This function can be removed once the deprecated code of non-codables is removed.
            """
    )
    private func logSuccessResponse(forURL URL: String, forResponse response: [String: Any]?) {
        let responseCode = response?["statusCode"] as? Int

        let originalResponse = self.responseWithoutStatusCode(response: response)

        self.logResponse(forURL: URL, responseCode: responseCode, responseBody: "\(originalResponse as AnyObject)")
    }

    private func logSuccessResponse<T: Codable>(
        forURL URL: String,
        withResponseCode responseCode: Int?,
        forResponse response: T
    ) {
        guard let responseData = try? JSONEncoder().encode(response) else {
            print("Success response received, but could not be encoded.")
            return
        }

        let responseString = String(decoding: responseData, as: UTF8.self)
        self.logResponse(forURL: URL, responseCode: responseCode, responseBody: responseString)
    }

    private func logFailureResponse(forURL URL: String, forError error: Error) {
        self.logResponse(
            forURL: URL,
            responseCode: error.asAFError?.responseCode,
            responseBody: "\(error.localizedDescription)",
            isError: true
        )
    }

    private func logApiFailureResponse(forURL URL: String, forApiError errorResponse: ApiErrorResponse) {
        self.logResponse(
            forURL: URL,
            responseCode: nil,
            responseBody: errorResponse.errors[0].message,
            isApiError: true
        )
    }

    /**
     * Logs all request headers, url and body
     */
    private func logRequest(forURL URL: String, requestMethod: HTTPMethod, postBody: Parameters? = nil) {
        var requestLog =
        """
        Request URL : \(URL)
        Request Method : \(requestMethod.rawValue)
        Request Headers : \n
        """

        httpHeaders.forEach { header in
            requestLog += " \(header) \n"
        }

        if requestMethod == .post {
            requestLog += "Body: \(postBody?.description ?? "")"
        }

        print(requestLog)
    }

    /**
     * Logs all response headers, status code and body
     */
    private func logResponse(
        forURL URL: String,
        responseCode: Int?,
        responseBody: String,
        isError: Bool = false,
        isApiError: Bool = false
    ) {
        var responseLog =
        """
        Response URL : \(URL)
        Response Code :
        """

        if let responseCode {
            responseLog += " \(responseCode) \n"
        } else {
            responseLog += " Nil \n"
        }

        responseLog += "Response Headers : \n"

        httpHeaders.forEach { header in
            responseLog += " \(header) \n"
        }

        if isApiError {
            responseLog += "API Error : "
        } else if isError {
            responseLog += "Response Error : "
        } else {
            responseLog += "Response Body : "
        }

        responseLog += responseBody

        print(responseLog)
    }
}
