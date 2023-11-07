//
//  ValidatorEmailAddress.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorEmailAddress: Validator {
    public var expression: NSRegularExpression

    public override init() {
        let regex = "^[^@\\.]+(\\.[^@\\.]+)*@([^@\\.]+\\.)*[^@\\.]+\\.[^@\\.][^@\\.]+$"

        guard let regex = try? NSRegularExpression(pattern: regex) else {
            fatalError("Could not create Regular Expression")
        }
        expression = regex
    }

    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        let numberOfMatches = expression.numberOfMatches(in: value, range: NSRange(location: 0, length: value.count))
        if numberOfMatches != 1 {
            let error = ValidationErrorEmailAddress()
            errors.append(error)
        }
    }
}
