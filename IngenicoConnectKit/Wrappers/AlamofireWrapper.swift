//
//  AlamofireWrapper.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import Alamofire

public class AlamofireWrapper {
    
    static let shared = AlamofireWrapper()

    public var headers: HTTPHeaders? {
        get {
            return URLSessionConfiguration.default.httpAdditionalHeaders as? HTTPHeaders
        }
        set {
            URLSessionConfiguration.default.httpAdditionalHeaders = newValue
        }
    }

    public func getResponse(forURL URL: String,
                            withParameters parameters:Parameters? = nil,
                            headers: HTTPHeaders?,
                            additionalAcceptableStatusCodes: IndexSet?,
                            success: @escaping (_ responseObject: [String: Any]?) -> Void,
                            failure: @escaping (_ error: Error) -> Void) {
        
        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200,length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }

        Alamofire
            .request(URL, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseJSON { response in
                if let error = response.result.error {
                    Macros.DLog(message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)")
                    failure(error)
                } else {
                    success(response.result.value as? [String: Any])
                }
        }
    }
    
    public func postResponse(forURL URL: String,
                             headers: HTTPHeaders?,
                             withParameters parameters: Parameters?,
                             additionalAcceptableStatusCodes: IndexSet?,
                             success: @escaping (_ responseObject: [String: Any]?) -> Void,
                             failure: @escaping (_ error: Error) -> Void) {
        
        let acceptableStatusCodes = NSMutableIndexSet(indexesIn: NSRange(location: 200,length: 100))
        if let additionalAcceptableStatusCodes = additionalAcceptableStatusCodes {
            acceptableStatusCodes.add(additionalAcceptableStatusCodes)
        }
        
        Alamofire
            .request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseJSON { response in
                if let error = response.result.error {
                    Macros.DLog(message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)")
                    failure(error)
                } else {
                    success(response.result.value as? [String: Any])
                }
        }
    }
}
