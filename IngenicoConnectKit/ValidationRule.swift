//
//  ValidationRule.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 18/12/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

public protocol ValidationRule {
    func validate(field fieldId: String, in request: PaymentRequest) -> Bool
}
