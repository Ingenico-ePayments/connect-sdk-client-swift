//
//  PaymentProduct302SpecificData.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 20/09/2018.
//  Copyright © 2018 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProduct302SpecificData {
    public var networks: [String] = []

    public required init?(json: [String: Any]) {
        if let networks = json["networks"] as? [String] {
            self.networks = networks
        }
    }
}
