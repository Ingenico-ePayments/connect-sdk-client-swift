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
            let headers = URLSessionConfiguration.default.httpAdditionalHeaders
            var httpHeaders: [HTTPHeader] = []
            headers?.forEach{
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

        AF.request(URL, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    success(value as? [String: Any])
                case .failure(let error):
                    Macros.DLog(message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)")
                    failure(error)
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
        
        AF.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    success(value as? [String: Any])
                case .failure(let error):
                    Macros.DLog(message: "Error while retrieving response for URL \(URL): \(error.localizedDescription)")
                    failure(error)
            }
        }
    }
}
