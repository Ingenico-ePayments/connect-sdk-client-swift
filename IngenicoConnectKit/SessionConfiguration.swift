//
//  SessionConfiguration.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 24/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

public class SessionConfiguration: Decodable {
    public let clientSessionId: String
    public let customerId: String
    public let clientApiUrl: String
    public let assetUrl: String

    public init(clientSessionId: String, customerId: String, clientApiUrl: String, assetUrl: String) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.clientApiUrl = clientApiUrl
        self.assetUrl = assetUrl
    }
}
