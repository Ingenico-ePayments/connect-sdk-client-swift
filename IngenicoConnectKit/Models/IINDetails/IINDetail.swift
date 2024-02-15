//
//  IINDetail.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class IINDetail: ResponseObjectSerializable, Codable {
    public var paymentProductId: String
    public var allowedInContext: Bool = false

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
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

    @available(*, deprecated, message: "In a future release, this intializer will become internal to the SDK.")
    public init(paymentProductId: String, allowedInContext: Bool) {
        self.paymentProductId = paymentProductId
        self.allowedInContext = allowedInContext
    }

    private enum CodingKeys: String, CodingKey {
        case paymentProductId, isAllowedInContext
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let paymentProductIdInt = try container.decode(Int.self, forKey: .paymentProductId)
        self.paymentProductId = "\(paymentProductIdInt)"
        if let allowedInContext = try? container.decodeIfPresent(Bool.self, forKey: .isAllowedInContext) {
            self.allowedInContext = allowedInContext
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(paymentProductId, forKey: .paymentProductId)
        try? container.encode(allowedInContext, forKey: .isAllowedInContext)
    }
}
