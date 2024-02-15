//
//  AccountOnFileAttribute.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class AccountOnFileAttribute: Codable {

    public var key: String
    public var value: String?
    public var status: AccountOnFileAttributeStatus
    public var mustWriteReason: String?

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init?(json: [String: Any]) {
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key
        value = json["value"] as? String
        mustWriteReason = json["mustWriteReason"] as? String

        switch json["status"] as? String {
        case "READ_ONLY"?:
            status = .readOnly
        case "CAN_WRITE"?:
            status = .canWrite
        case "MUST_WRITE"?:
            status = .mustWrite
        default:
            Macros.DLog(message: "Status \(json["status"]!) in JSON fragment status is invalid")
            return nil
        }
    }
}
