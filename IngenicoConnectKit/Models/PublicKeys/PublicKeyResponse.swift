//
//  PublicKeyResponse.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PublicKeyResponse {
    public var keyId: String
    public var encodedPublicKey: String

    public init(keyId: String, encodedPublicKey: String) {
        self.keyId = keyId
        self.encodedPublicKey = encodedPublicKey
    }
}
