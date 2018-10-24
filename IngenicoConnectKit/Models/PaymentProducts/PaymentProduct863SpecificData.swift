//
//  PaymentProduct863SpecificData.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 20/09/2018.
//  Copyright © 2018 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProduct863SpecificData {
    public var integrationTypes: [String] = []
    public required init?(json: [String: Any]) {
        if let integrationTypes = json["integrationTypes"] as? [String] {
            self.integrationTypes = integrationTypes
        }
    }

}
