//
//  ClientApiCommunicator.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 24/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation
import Alamofire
import PassKit

internal struct ClientApiCommunicator {
    private var sdkConfiguration: ConnectSDKConfiguration
    private let paymentConfiguration: PaymentConfiguration
    private let networkingWrapper = AlamofireWrapper.shared
    private let util = Util()

    private var baseURL: String

    private var clientSessionId: String {
        return sdkConfiguration.sessionConfiguration.clientSessionId
    }

    private var customerId: String {
        return sdkConfiguration.sessionConfiguration.customerId
    }

    internal var assetUrl: String {
        return sdkConfiguration.sessionConfiguration.assetUrl
    }

    internal var base64EncodedClientMetaInfo: String {
        return
            util.base64EncodedClientMetaInfo(
                withAppIdentifier: sdkConfiguration.applicationId,
                ipAddress: sdkConfiguration.ipAddress
            ) ?? ""
    }

    private var loggingEnabled: Bool {
        return sdkConfiguration.enableNetworkLogs
    }

    private var paymentContext: PaymentContext {
        return paymentConfiguration.paymentContext
    }

    internal var groupPaymentProducts: Bool {
        return paymentConfiguration.groupPaymentProducts
    }

    private var httpHeaders: HTTPHeaders {
        return [
            "Authorization": "GCS v1Client:\(clientSessionId)",
            "X-GCS-ClientMetaInfo": base64EncodedClientMetaInfo
        ]
    }

    init(sdkConfiguration: ConnectSDKConfiguration, paymentConfiguration: PaymentConfiguration) {
        self.sdkConfiguration = sdkConfiguration
        self.paymentConfiguration = paymentConfiguration
        self.baseURL = Self.fixBaseURL(url: sdkConfiguration.sessionConfiguration.clientApiUrl)
    }

    func thirdPartyStatus(
        forPayment paymentId: String,
        success: @escaping (_ thirdPartyStatusResponse: ThirdPartyStatusResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let URL = "\(baseURL)/\(customerId)/payments/\(paymentId)/thirdpartystatus"

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
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func paymentProducts(
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let isRecurring = paymentContext.isRecurring ? "true" : "false"
        let URL = "\(baseURL)/\(customerId)/products"
        var params: [String: Any] =
            [
                "countryCode": paymentContext.countryCodeString,
                "currencyCode": paymentContext.amountOfMoney.currencyCodeString,
                "amount": paymentContext.amountOfMoney.totalAmount,
                "hide": "fields",
                "isRecurring": isRecurring
            ]

        if let locale = paymentContext.locale {
            params["locale"] = locale
        }

        getResponse(
            forURL: URL,
            withParameters: params,
            success: { (responseObject: BasicPaymentProducts?) in
                guard let paymentProductsResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                self.checkApplePayAvailability(
                    with: paymentProductsResponse,
                    success: { paymentProductsFilteredApplePay in
                        success(paymentProductsFilteredApplePay)
                    },
                    failure: failure,
                    apiFailure: apiFailure
                )
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func checkApplePayAvailability(
        with paymentProducts: BasicPaymentProducts,
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        if let applePayPaymentProduct =
            paymentProducts.paymentProduct(withIdentifier: SDKConstants.kApplePayIdentifier) {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") &&
                PKPaymentAuthorizationViewController.canMakePayments() {
                paymentProductNetworks(
                    forProduct: SDKConstants.kApplePayIdentifier,
                    success: { (_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                        if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct),
                            !PKPaymentAuthorizationViewController.canMakePayments(
                                usingNetworks: paymentProductNetworks.paymentProductNetworks
                            ) {
                            paymentProducts.paymentProducts.remove(at: product)
                        }
                        success(paymentProducts)
                    },
                    failure: failure,
                    apiFailure: apiFailure
                )
            } else {
                if let product = paymentProducts.paymentProducts.firstIndex(of: applePayPaymentProduct) {
                    paymentProducts.paymentProducts.remove(at: product)
                }

                success(paymentProducts)
            }
        } else {
            success(paymentProducts)
        }
    }

    func paymentProductNetworks(
        forProduct paymentProductId: String,
        success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let isRecurring = paymentContext.isRecurring ? "true" : "false"
        guard let locale = paymentContext.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }
        let URL = "\(self.baseURL)/\(customerId)/products/\(paymentProductId)/networks"
        let params: [String: Any] =
            [
                "countryCode": paymentContext.countryCodeString,
                "locale": locale,
                "currencyCode": paymentContext.amountOfMoney.currencyCodeString,
                "amount": paymentContext.amountOfMoney.totalAmount,
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
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func paymentProductGroups(
        success: @escaping (_ paymentProductGroups: BasicPaymentProductGroups) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let isRecurring = paymentContext.isRecurring ? "true" : "false"
        guard let locale = paymentContext.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }

        let URL = "\(baseURL)/\(customerId)/productgroups"
        let params: [String: Any] =
            [
                "countryCode": paymentContext.countryCodeString,
                "locale": locale,
                "currencyCode": paymentContext.amountOfMoney.currencyCodeString,
                "amount": paymentContext.amountOfMoney.totalAmount,
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
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func paymentProduct(
        withId paymentProductId: String,
        success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        checkApplePayAvailability(
            forProduct: paymentProductId,
            success: {() -> Void in
                let isRecurring = paymentContext.isRecurring ? "true" : "false"

                let URL = "\(self.baseURL)/\(customerId)/products/\(paymentProductId)/"
                var params: [String: Any] =
                [
                    "countryCode": paymentContext.countryCodeString,
                    "currencyCode": paymentContext.amountOfMoney.currencyCodeString,
                    "amount": paymentContext.amountOfMoney.totalAmount,
                    "isRecurring": isRecurring
                ]
                if let forceBasicFlow = paymentContext.forceBasicFlow {
                    params["forceBasicFlow"] = forceBasicFlow ? "true" : "false"
                }
                if let locale = paymentContext.locale {
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
                    },
                    failure: failure,
                    apiFailure: apiFailure
                )
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    private func checkApplePayAvailability(
        forProduct paymentProductId: String,
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        if paymentProductId == SDKConstants.kApplePayIdentifier {
            if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") &&
                PKPaymentAuthorizationViewController.canMakePayments() {
                paymentProductNetworks(
                    forProduct: SDKConstants.kApplePayIdentifier,
                    success: { (_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                        if !PKPaymentAuthorizationViewController.canMakePayments(
                            usingNetworks: paymentProductNetworks.paymentProductNetworks
                        ) {
                            failure(self.badRequestError(forProduct: paymentProductId))
                        } else {
                            success()
                        }
                    },
                    failure: failure,
                    apiFailure: apiFailure
                )
            } else {
                failure(badRequestError(forProduct: paymentProductId))
            }
        } else {
            success()
        }
    }

    private func badRequestError(forProduct paymentProductId: String) -> Error {
        let url = createBadRequestErrorURL(forProduct: paymentProductId)
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

    private func createBadRequestErrorURL(forProduct paymentProductId: String) -> String {
        let isRecurring = paymentContext.isRecurring ? "true" : "false"
        // swiftlint:disable line_length
        return
            "\(baseURL)/\(customerId)/products/\(paymentProductId)/?countryCode=\(paymentContext.countryCodeString)&locale=\(paymentContext.locale!)&currencyCode=\(paymentContext.amountOfMoney.currencyCodeString)&amount=\(UInt(paymentContext.amountOfMoney.totalAmount))&isRecurring=\(isRecurring)"
        // swiftlint:enable line_length
    }

    func paymentProductGroup(
        withId paymentProductGroupId: String,
        success: @escaping (_ paymentProductGroup: PaymentProductGroup) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let isRecurring = paymentContext.isRecurring ? "true" : "false"

        guard let locale = paymentContext.locale else {
            failure(SessionError.RuntimeError("Locale was nil."))
            return
        }

        let URL = "\(baseURL)/\(customerId)/productgroups/\(paymentProductGroupId)/"
        let params: [String: Any] =
            [
                "countryCode": paymentContext.countryCodeString,
                 "locale": locale,
                 "currencyCode": paymentContext.amountOfMoney.currencyCodeString,
                 "amount": paymentContext.amountOfMoney.totalAmount,
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
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func publicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let URL = "\(baseURL)/\(customerId)/crypto/publickey"

        getResponse(
            forURL: URL,
            success: { (responseObject: PublicKeyResponse?) -> Void in
                guard let publicKeyResponse = responseObject else {
                    failure(SessionError.RuntimeError("Response was empty."))
                    return
                }

                success(publicKeyResponse)
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    func iinDetails(
        forPartialCreditCardNumber partialCreditCardNumber: String,
        success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let URL = "\(baseURL)/\(customerId)/services/getIINdetails"

        var parameters: [String: Any] = [:]
        parameters["bin"] = getIINDigitsFrom(partialCreditCardNumber: partialCreditCardNumber)

        var paymentContextParameters: [String: Any] = [:]
        paymentContextParameters["isRecurring"] = paymentContext.isRecurring ? "true" : "false"
        paymentContextParameters["countryCode"] = paymentContext.countryCodeString

        var amountOfMoney: [String: Any] = [:]
        amountOfMoney["amount"] = String(paymentContext.amountOfMoney.totalAmount)
        amountOfMoney["currencyCode"] = paymentContext.amountOfMoney.currencyCodeString
        paymentContextParameters["amountOfMoney"] = amountOfMoney

        parameters["paymentContext"] = paymentContextParameters

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
            failure: failure,
            apiFailure: apiFailure
        )
    }

    private func getIINDigitsFrom(partialCreditCardNumber: String) -> String {
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

    // swiftlint:disable function_parameter_count
    func convert(
        amountInCents: Int,
        sourceCurrency: String,
        targetCurrency: String,
        success: @escaping (_ convertedAmountResponse: ConvertedAmountResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let amount = "\(amountInCents)"
        let URL = "\(baseURL)/\(customerId)/services/convert/amount"
        let params: [String: Any] = ["source": sourceCurrency, "target": targetCurrency, "amount": amount]

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
            failure: failure,
            apiFailure: apiFailure
        )
    }
    // swiftlint:enable function_parameter_count

    func directory(
        forProduct paymentProductId: String,
        success: @escaping (_ directoryEntries: DirectoryEntries) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let URL = "\(baseURL)/\(customerId)/products/\(paymentProductId)/directory"
        let params: [String: Any] =
            [
                "countryCode": paymentContext.countryCodeString,
                "currencyCode": paymentContext.amountOfMoney.currencyCodeString
            ]

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
            failure: failure,
            apiFailure: apiFailure
        )
    }

    private func getResponse<T: Codable>(
        forURL URL: String,
        withParameters parameters: Parameters? = nil,
        success: @escaping (_ responseObject: T?) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
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
                apiFailure(errorResponse)
            }
        )
    }

    // swiftlint:disable function_parameter_count
    private func postResponse<T: Codable>(
        forURL URL: String,
        withParameters parameters: [AnyHashable: Any],
        additionalAcceptableStatusCodes: IndexSet?,
        success: @escaping (_ responseObject: T?) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
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
                apiFailure(errorResponse)
            }
        )
    }
    // swiftlint:enable function_parameter_count

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

    private static func fixBaseURL(url: String) -> String {
        guard var finalComponents = URLComponents(string: url) else {
            fatalError("The provided url: \(url) is malformed.")
        }

        var components = finalComponents.path.split(separator: "/").map { String($0)}
        let versionComponents = (SDKConstants.kApiVersion as NSString).pathComponents
        let error = {
            fatalError(
                """
                This version of the connectSDK is only compatible with \(versionComponents.joined(separator: "/")),
                you supplied: '\(components.joined(separator: "/"))'
                """
            )
        }

        switch components.count {
        case 0:
            components = versionComponents
        case 1:
            if components[0] != versionComponents[0] {
                error()
            }
            components[0] = components[0]
            components.append(versionComponents[1])
        case 2:
            if components[0] != versionComponents[0] {
                error()
            }
            if components[1] != versionComponents[1] {
                error()
            }
        default:
            error()
        }
        finalComponents.path = "/" + components.joined(separator: "/")
        guard let finalComponentsUrl = finalComponents.url else {
            fatalError("Could not return the url of \(finalComponents).")
        }

        return finalComponentsUrl.absoluteString
    }
}
