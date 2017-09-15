//
//  ThirdPartyStatusResponse.swift
//  Pods
//
//  Created for Ingenico ePayments on 15/06/2017.
//
//

import UIKit

public class ThirdPartyStatusResponse: ResponseObjectSerializable {
    public var thirdPartyStatus: ThirdPartyStatus
    
    public required init?(json: [String : Any]) {
        if let input = json["thirdPartyStatus"] as? ThirdPartyStatus {
            thirdPartyStatus = input
        } else {
            return nil
        }
    }

}
