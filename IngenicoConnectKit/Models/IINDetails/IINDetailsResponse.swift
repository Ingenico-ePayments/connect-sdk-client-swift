//
//  IINDetailsResponse.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class IINDetailsResponse: ResponseObjectSerializable {
    
    public var paymentProductId: String?
    public var status: IINStatus = .supported
    public var coBrands = [IINDetail]()
    @available(*, deprecated, message: "In the next major release, the type of countryCode will change to String.")
    public var countryCode: CountryCode?
    public var countryCodeString: String?
    public var allowedInContext = false
    
    private init() {
    }
    
    required public init(json: [String : Any]) {
        if let input = json["isAllowedInContext"] as? Bool {
            allowedInContext = input
        }
        
        if let input = json["paymentProductId"] as? Int {
            paymentProductId = "\(input)"
        } else if !allowedInContext {
            status = .existingButNotAllowed
        } else {
            status = .unknown
        }
        if let input = json["countryCode"] as? String {
            countryCode = CountryCode(rawValue: input)
            countryCodeString = input
        }
        
        if let input = json["coBrands"] as? [[String: Any]] {
            coBrands = []
            for detailInput in input {
                if let detail = IINDetail(json: detailInput) {
                    coBrands.append(detail)
                }
            }
        }
    }
    
    convenience public init(status: IINStatus) {
        self.init()
        self.status = status
    }
    
    
    @available(*, deprecated, message: "Use init(String, IINStatus, [IINDEtail], String) instead")
    convenience public init(paymentProductId: String, status: IINStatus, coBrands: [IINDetail], countryCode: CountryCode, allowedInContext: Bool) {
        self.init(paymentProductId: paymentProductId, status: status, coBrands: coBrands, countryCode: countryCode.rawValue, allowedInContext: allowedInContext)
    }
    
    convenience public init(paymentProductId: String, status: IINStatus, coBrands: [IINDetail], countryCode: String, allowedInContext: Bool) {
        self.init()
        self.paymentProductId = paymentProductId
        self.status = status
        self.coBrands = coBrands
        self.countryCodeString = countryCode
        self.allowedInContext = allowedInContext
    }
}
