//
//  SessionError.swift
//  IngenicoConnectKit
//
//  Created by Fabian Giger on 15-03-17.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//
// swiftlint:disable identifier_name

@available(
    *,
    deprecated,
    message:
        """
        In a future release, this enum will be removed. The SDK will throw a ConnectSDKError instead.
        """
)
public enum SessionError: Error {
    case RuntimeError(String)
}
// swiftlint:enable identifier_name
