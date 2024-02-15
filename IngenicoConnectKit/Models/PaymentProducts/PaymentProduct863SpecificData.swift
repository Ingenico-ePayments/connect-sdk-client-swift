//
//  PaymentProduct863SpecificData.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 20/09/2018.
//  Copyright © 2018 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProduct863SpecificData: Codable {
    public var integrationTypes: [String] = []

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public required init?(json: [String: Any]) {
        if let integrationTypes = json["integrationTypes"] as? [String] {
            self.integrationTypes = integrationTypes
        }
    }

    private enum CodingKeys: String, CodingKey {
        case integrationTypes
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.integrationTypes = (try? container.decode([String].self, forKey: .integrationTypes)) ?? []
    }
}
