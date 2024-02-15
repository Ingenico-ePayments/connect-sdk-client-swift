//
//  PublicKeyResponse.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PublicKeyResponse: Codable {
    public var keyId: String
    public var encodedPublicKey: String

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public init(keyId: String, encodedPublicKey: String) {
        self.keyId = keyId
        self.encodedPublicKey = encodedPublicKey
    }

    private enum CodingKeys: String, CodingKey {
        case keyId, publicKey
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyId = try container.decode(String.self, forKey: .keyId)
        self.encodedPublicKey = try container.decode(String.self, forKey: .publicKey)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(keyId, forKey: .keyId)
        try? container.encode(encodedPublicKey, forKey: .publicKey)
    }
}
