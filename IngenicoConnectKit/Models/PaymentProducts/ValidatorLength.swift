//
//  ValidatorLength.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorLength: Validator, ValidationRule, ResponseObjectSerializable {
    public var minLength = 0
    public var maxLength = 0

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public init(minLength: Int?, maxLength: Int?) {
        self.minLength = minLength ?? 0
        self.maxLength = maxLength ?? 0

        super.init(messageId: "length", validationType: .length)
    }

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public required init(json: [String: Any]) {
        if let input = json["maxLength"] as? Int {
            maxLength = input
        }
        if let input = json["minLength"] as? Int {
            minLength = input
        }

        super.init(messageId: "length", validationType: .length)
    }

    private enum CodingKeys: String, CodingKey {
        case minLength, maxLength
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.minLength = (try? container.decodeIfPresent(Int.self, forKey: .minLength)) ?? 0
        self.maxLength = (try? container.decodeIfPresent(Int.self, forKey: .maxLength)) ?? 0

        super.init(messageId: "length", validationType: .length)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(minLength, forKey: .minLength)
        try? container.encode(maxLength, forKey: .maxLength)

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

        if value.count < minLength || value.count > maxLength {
            let error =
                ValidationErrorLength(
                    errorMessage: self.messageId,
                    paymentProductFieldId: fieldId,
                    rule: self
                )
            error.minLength = minLength
            error.maxLength = maxLength
            errors.append(error)

            return false
        }

        return true
    }
}
