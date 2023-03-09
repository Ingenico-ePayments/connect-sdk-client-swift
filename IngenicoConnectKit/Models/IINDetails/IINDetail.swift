//
//  IINDetail.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class IINDetail: ResponseObjectSerializable {
    public var paymentProductId: String
    public var allowedInContext: Bool = false

    required public init?(json: [String: Any]) {
        if let input = json["paymentProductId"] as? Int {
            paymentProductId = "\(input)"
        } else {
            return nil
        }
        if let input = json["isAllowedInContext"] as? Bool {
            allowedInContext = input
        }
    }

    public init(paymentProductId: String, allowedInContext: Bool) {
        self.paymentProductId = paymentProductId
        self.allowedInContext = allowedInContext
    }
}
