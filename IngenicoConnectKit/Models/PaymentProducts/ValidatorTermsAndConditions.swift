//
//  ValidatorEmailAddress.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 09/01/2018.
//  Copyright © 2018 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorTermsAndConditions: Validator {
    public override init() {
        super.init()
    }

    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)
        if (!(Bool(value) ?? false)) {
            let error = ValidationErrorTermsAndConditions()
            errors.append(error)
        }
    }
}
