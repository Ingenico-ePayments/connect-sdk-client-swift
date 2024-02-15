//
//  ConnectSDKError.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 27/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

public enum ConnectSDKError: Int, Error {
    case connectSDKNotInitialized
    case publicKeyDecodeError
    case rsaKeyNotFound
}

extension ConnectSDKError: LocalizedError {
    public var errorDescription: String {
        switch self {
        case .connectSDKNotInitialized:
            return
                """
                ConnectSDK must be initialized before you can perform this operation.
                Initialize it by calling ConnectSDK.initialize()
                """
        case .publicKeyDecodeError:
            return "Failed to decode Public key."
        case .rsaKeyNotFound:
            return "Failed to find RSA key."
        }
    }
}
