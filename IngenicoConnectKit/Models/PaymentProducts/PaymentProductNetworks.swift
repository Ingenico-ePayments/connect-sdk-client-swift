//
//  PaymentProductNetworks.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import PassKit

public class PaymentProductNetworks: Codable {

    public var paymentProductNetworks = [PKPaymentNetwork]()

    private enum CodingKeys: String, CodingKey {
        case networks
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let networks = try? container.decode([String].self, forKey: .networks) {
            for network in networks {
                let paymentNetwork = PKPaymentNetwork(rawValue: network)
                self.paymentProductNetworks.append(paymentNetwork)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        var networks = [String]()

        for network in paymentProductNetworks {
            networks.append(network.rawValue)
        }

        try? container.encode(networks, forKey: .networks)
    }
}
