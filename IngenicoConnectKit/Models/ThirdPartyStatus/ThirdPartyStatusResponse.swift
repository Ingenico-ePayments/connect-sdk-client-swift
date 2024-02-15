//
//  ThirdPartyStatusResponse.swift
//  Pods
//
//  Created for Ingenico ePayments on 15/06/2017.
//
//

import UIKit

public class ThirdPartyStatusResponse: ResponseObjectSerializable, Codable {
    public var thirdPartyStatus: ThirdPartyStatus

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public required init?(json: [String: Any]) {
        if let urlStr = json["thirdPartyStatus"] as? String {
            if let input = ThirdPartyStatus(rawValue: urlStr) {
                thirdPartyStatus = input
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

}
