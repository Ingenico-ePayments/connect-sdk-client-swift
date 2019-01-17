//
//  PaymentProduct320SpecificData.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 20/09/2018.
//  Copyright © 2018 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProduct320SpecificData {
    public var gateway: String = ""
    public var networks: [String] = []
    
    public required init?(json: [String: Any]) {
        if let gateway = json["gateway"] as? String {
            self.gateway = gateway
        }
        if let networks = json["networks"] as? [String] {
            self.networks = networks
        }
    }
}
