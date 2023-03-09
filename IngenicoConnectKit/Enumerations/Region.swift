//
//  Region.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//
// swiftlint:disable identifier_name

@available(
    *,
    deprecated,
    message: """
             Use the clientApiUrl and assetUrl returned in the server to server Create Client Session API
             to obtain the endpoints for the Client API.
             """
)
public enum Region {
    case EU
    case US
    case AMS
    case PAR
}
