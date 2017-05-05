//
//  Validator.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class Validator {
    public var errors: [ValidationError] = []

    public func validate(value: String, for: PaymentRequest) {
        errors.removeAll()
    }
}
