//
//  ValidatorFixedList.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorFixedList: Validator, ValidationRule, ResponseObjectSerializable {
    public var allowedValues: [String] = []

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public init(allowedValues: [String]) {
        self.allowedValues = allowedValues

        super.init(messageId: "fixedList", validationType: .fixedList)
    }

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init(json: [String: Any]) {
        if let input = json["allowedValues"] as? [String] {
            for inputString in input {
                allowedValues.append(inputString)
            }
        }

        super.init(messageId: "fixedList", validationType: .fixedList)
    }

    private enum CodingKeys: String, CodingKey {
        case allowedValues
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let allowedValues = try? container.decodeIfPresent([String].self, forKey: .allowedValues) {
            self.allowedValues = allowedValues
        }

        super.init(messageId: "fixedList", validationType: .fixedList)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(allowedValues, forKey: .allowedValues)

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

        for allowedValue in allowedValues where allowedValue.isEqual(value) {
            return true
        }

        let error =
            ValidationErrorFixedList(
                errorMessage: self.messageId,
                paymentProductFieldId: fieldId,
                rule: self
            )
        errors.append(error)

        return false
    }
}
