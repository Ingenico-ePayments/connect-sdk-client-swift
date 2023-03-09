//
//  ValidatorRange.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorRange: Validator, ResponseObjectSerializable {
    public var minValue = 0
    public var maxValue = 0
    public var formatter = NumberFormatter()

    public init(minValue: Int?, maxValue: Int?) {
        self.minValue = minValue ?? 0
        self.maxValue = maxValue ?? 0
    }

    required public init(json: [String: Any]) {
        if let input = json["maxValue"] as? Int {
            maxValue = input
        }
        if let input = json["minValue"] as? Int {
            minValue = input
        }
    }

    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        let error = ValidationErrorRange()
        error.minValue = minValue
        error.maxValue = maxValue

        guard let number = formatter.number(from: value) else {
            errors.append(error)
            return
        }

        if Int(truncating: number) < minValue {
            errors.append(error)
        } else if Int(truncating: number) > maxValue {
            errors.append(error)
        }
    }
}
