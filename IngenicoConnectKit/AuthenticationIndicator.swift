//
//  AuthenticationIndicator.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 09/03/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

public class AuthenticationIndicator: ResponseObjectSerializable {
    public var name: String
    public var value: String

    public required init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
              let value = json["value"] as? String else {
            return nil
        }

        self.name = name
        self.value = value
    }
}
