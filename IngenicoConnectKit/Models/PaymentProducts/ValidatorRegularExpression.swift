//
//  ValidatorRegularExpression.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorRegularExpression: Validator, ValidationRule, ResponseObjectSerializable {

    public var regularExpression: NSRegularExpression

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public init(regularExpression: NSRegularExpression) {
        self.regularExpression = regularExpression

        super.init(messageId: "regularExpression", validationType: .regularExpression)
    }

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public required init?(json: [String: Any]) {
        guard let input = json["regularExpression"] as? String,
              let regularExpression = try? NSRegularExpression(pattern: input) else {
            Macros.DLog(message: "Expression: \(json["regularExpression"]!) is invalid")
            return nil
        }

        self.regularExpression = regularExpression

        super.init(messageId: "regularExpression", validationType: .regularExpression)
    }

    private enum CodingKeys: String, CodingKey {
        case regularExpression, regex
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let regularExpressionInput = try?
                container.decodeIfPresent(String.self, forKey: .regularExpression) ??
                container.decodeIfPresent(String.self, forKey: .regex),
              let regularExpression = try? NSRegularExpression(pattern: regularExpressionInput) else {
            throw SessionError.RuntimeError("Regular expression is invalid")
        }
        self.regularExpression = regularExpression

        super.init(messageId: "regularExpression", validationType: .regularExpression)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(regularExpression.pattern, forKey: .regex)

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

        let numberOfMatches =
            regularExpression.numberOfMatches(in: value, range: NSRange(location: 0, length: value.count))
        if numberOfMatches != 1 {
            let error =
                ValidationErrorRegularExpression(
                    errorMessage: self.messageId,
                    paymentProductFieldId: fieldId,
                    rule: self
                )
            errors.append(error)

            return false
        }

        return true
    }
}
