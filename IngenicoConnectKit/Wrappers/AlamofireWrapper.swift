//
//  AlamofireWrapper.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import Alamofire

@available(
    *,
    deprecated,
    message:
        """
        In a future release, this class, its functions and its properties will become internal to the SDK.
        Please use Session to interact with the API.
        """
)
public class AlamofireWrapper {

    static let shared = AlamofireWrapper()

    public var headers: HTTPHeaders? {
        get {
            let headers = URLSessionConfiguration.default.httpAdditionalHeaders
            var httpHeaders: [HTTPHeader] = []
            headers?.forEach {
                if let key = $0.key as? String, let value = $0.value as? String {
                    httpHeaders.append(HTTPHeader(name: key, value: value))
                }
            }
            return HTTPHeaders(httpHeaders)
        }
        set {
            URLSessionConfiguration.default.httpAdditionalHeaders = newValue?.dictionary
        }
    }

    // swiftlint:disable function_parameter_count
    @available(*, deprecated, message: "In a future release, this function will be removed.")
    public func getResponse(forURL URL: String,
                            withParameters parameters: Parameters? = nil,
                            headers: HTTPHeaders?,
                            additionalAcceptableStatusCodes: IndexSet?,
                            success: @escaping (_ responseObject: [String: Any]?) -> Void,
                            failure: @escaping (_ error: Error) -> Void) {

        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200, length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        AF.request(URL, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    var responseObject = value as? [String: Any]
                                        responseObject?["statusCode"] = response.response?.statusCode

                                        success(responseObject)
                case .failure(let error):
                    Macros.DLog(
                        message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)"
                    )
                    failure(error)
                }
            }
    }

    internal func getResponse<T: Codable>(forURL URL: String,
                                          headers: HTTPHeaders?,
                                          withParameters parameters: Parameters? = nil,
                                          additionalAcceptableStatusCodes: IndexSet?,
                                          success: @escaping ((responseObject: T?, statusCode: Int?)) -> Void,
                                          failure: @escaping (_ error: Error) -> Void,
                                          apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200, length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        AF.request(URL, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of: T.self) { response in
                if let error = response.error {
                    if error.responseCode != nil {
                        // Error related to unacceptable status code
                        // If decoding fails, return a failure instead of api failure
                        guard let apiError =
                                try? JSONDecoder().decode(ApiErrorResponse.self, from: response.data ?? Data()) else {
                            failure(error)
                            return
                        }

                        apiFailure(apiError)
                    } else {
                        // Error unrelated to status codes
                        Macros.DLog(
                            message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)"
                        )
                        failure(error)
                    }
                } else {
                    success((response.value, response.response?.statusCode))
                }
            }
    }

    @available(*, deprecated, message: "In a future release, this function will be removed.")
    public func postResponse(forURL URL: String,
                             headers: HTTPHeaders?,
                             withParameters parameters: Parameters?,
                             additionalAcceptableStatusCodes: IndexSet?,
                             success: @escaping (_ responseObject: [String: Any]?) -> Void,
                             failure: @escaping (_ error: Error) -> Void) {

        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200, length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        AF.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    var responseObject = value as? [String: Any]
                                        responseObject?["statusCode"] = response.response?.statusCode

                                        success(responseObject)
                case .failure(let error):
                    Macros.DLog(
                        message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)"
                    )
                    failure(error)
                }
            }
    }

    internal func postResponse<T: Codable>(forURL URL: String,
                                           headers: HTTPHeaders?,
                                           withParameters parameters: Parameters?,
                                           additionalAcceptableStatusCodes: IndexSet?,
                                           success: @escaping ((responseObject: T?, statusCode: Int?)) -> Void,
                                           failure: @escaping (_ error: Error) -> Void,
                                           apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200, length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        AF.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of: T.self) { response in
                if let error = response.error {
                    if error.responseCode != nil {
                        // Error related to unacceptable status code
                        // If decoding fails, return a failure instead of api failure
                        guard let apiError =
                                try? JSONDecoder().decode(ApiErrorResponse.self, from: response.data ?? Data()) else {
                            failure(error)
                            return
                        }

                        apiFailure(apiError)
                    } else {
                        // Error unrelated to status codes
                        Macros.DLog(
                            message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)"
                        )
                        failure(error)
                    }
                } else {
                    success((response.value, response.response?.statusCode))
                }
            }
    }
    // swiftlint:enable function_parameter_count
}
