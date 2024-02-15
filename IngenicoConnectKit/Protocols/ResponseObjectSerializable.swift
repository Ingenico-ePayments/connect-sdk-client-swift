//
//  ResponseObjectSerializable.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "In a future release, this protocol will be removed.")
public protocol ResponseObjectSerializable {
    init?(json: [String: Any])
}
