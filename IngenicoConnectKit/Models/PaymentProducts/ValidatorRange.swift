//
//  ValidatorRange.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorRange: Validator, ValidationRule, ResponseObjectSerializable {
    public var minValue = 0
    public var maxValue = 0
    public var formatter = NumberFormatter()

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public init(minValue: Int?, maxValue: Int?) {
        self.minValue = minValue ?? 0
        self.maxValue = maxValue ?? 0

        super.init(messageId: "range", validationType: .range)
    }

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init(json: [String: Any]) {
        if let input = json["maxValue"] as? Int {
            maxValue = input
        }
        if let input = json["minValue"] as? Int {
            minValue = input
        }

        super.init(messageId: "range", validationType: .range)
    }

    private enum CodingKeys: String, CodingKey {
        case minValue, maxValue
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.minValue = (try? container.decodeIfPresent(Int.self, forKey: .minValue)) ?? 0
        self.maxValue = (try? container.decodeIfPresent(Int.self, forKey: .maxValue)) ?? 0

        super.init(messageId: "range", validationType: .range)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(minValue, forKey: .minValue)
        try? container.encode(maxValue, forKey: .maxValue)

        try? super.encode(to: encoder)
    }

    @available(
        *,
        deprecated,
        message: "In a future release, this function will be removed. Please use validate(field:in:) instead."
    )
    public override func validate(value: String, for request: PaymentRequest) {
        _ = validate(value: value, for: nil)
    }

    public func validate(field fieldId: String, in request: PaymentRequest) -> Bool {
        guard let fieldValue = request.getValue(forField: fieldId) else {
            return false
        }

        return validate(value: fieldValue, for: fieldId)
    }

    internal override func validate(value: String, for fieldId: String?) -> Bool {
        self.clearErrors()

        let error = ValidationErrorRange(errorMessage: self.messageId, paymentProductFieldId: fieldId, rule: self)
        error.minValue = minValue
        error.maxValue = maxValue

        guard let number = formatter.number(from: value) else {
            errors.append(error)

            return false
        }

        if Int(truncating: number) < minValue || Int(truncating: number) > maxValue {
            errors.append(error)

            return false
        }

        return true
    }
}
