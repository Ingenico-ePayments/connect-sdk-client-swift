//
//  PaymentProductField.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProductField: ResponseObjectSerializable, Codable {

    public var identifier: String
    public var usedForLookup: Bool = false
    public var dataRestrictions = DataRestrictions()
    public var displayHints: PaymentProductFieldDisplayHints
    public var type: FieldType

    @available(*, deprecated, message: "In a future release, this property will become private to this class.")
    public var numberFormatter = NumberFormatter()
    @available(*, deprecated, message: "In a future release, this property will become private to this class.")
    public var numericStringCheck: NSRegularExpression
    private let stringFormatter = StringFormatter()

    public var errorMessageIds: [ValidationError] = []
    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed. Use errorMessageIds instead."
    )
    public var errors: [ValidationError] = []

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public required init?(json: [String: Any]) {
        guard let identifier = json["id"] as? String,
              let hints = json["displayHints"] as? [String: Any],
              let displayHints = PaymentProductFieldDisplayHints(json: hints),
              let numericStringCheck = try? NSRegularExpression(pattern: "^\\d+$")
        else {
            return nil
        }
        self.identifier = identifier
        self.displayHints = displayHints

        numberFormatter.numberStyle = .decimal
        self.numericStringCheck = numericStringCheck

        if let input = json["dataRestrictions"] as? [String: Any] {
            dataRestrictions = DataRestrictions(json: input)
        }

        if let usedForLookup = json["usedForLookup"] as? Bool {
            self.usedForLookup = usedForLookup
        }

        switch json["type"] as? String {
        case "string"?:
            type = .string
        case "integer"?:
            type = .integer
        case "expirydate"?:
            type = .expirationDate
        case "numericstring"?:
            type = .numericString
        case "boolean"?:
            type = .boolString
        case "date"?:
            type = .dateString
        default:
            Macros.DLog(message: "Type \(json["type"]!) in JSON fragment \(json) is invalid")
                return nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayHints, dataRestrictions, usedForLookup, type
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .id)
        self.displayHints = try container.decode(PaymentProductFieldDisplayHints.self, forKey: .displayHints)
        self.dataRestrictions =
            (try? container.decodeIfPresent(DataRestrictions.self, forKey: .dataRestrictions)) ?? DataRestrictions()
        self.usedForLookup = (try? container.decodeIfPresent(Bool.self, forKey: .usedForLookup)) ?? false
        self.type = (try? container.decodeIfPresent(FieldType.self, forKey: .type)) ?? .string

        self.numberFormatter.numberStyle = .decimal
        guard let numericStringCheck = try? NSRegularExpression(pattern: "^\\d+$") else {
            throw SessionError.RuntimeError("Could not create regular expression")
        }
        self.numericStringCheck = numericStringCheck
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(identifier, forKey: .id)
        try? container.encode(displayHints, forKey: .displayHints)
        try? container.encode(dataRestrictions, forKey: .dataRestrictions)
        try? container.encode(usedForLookup, forKey: .usedForLookup)
        try? container.encode(type, forKey: .type)
    }

    // periphery:ignore
    @available(
        *,
        deprecated,
        message:
            """
            In a future release, this function will be removed.
            Please use validateValue(value:) or validateValue(for:) instead.
            """
    )
    public func validateValue(value: String, for request: PaymentRequest) -> [ValidationError] {
        return validateValue(value: value)
    }

    public func validateValue(for request: PaymentRequest) -> [ValidationError] {
        guard let value = request.getValue(forField: identifier) else {
            return validateValue(value: "")
        }

        return validateValue(value: value)
    }

    public func validateValue(value: String) -> [ValidationError] {
        errors.removeAll()
        errorMessageIds.removeAll()

        if dataRestrictions.isRequired && value.isEqual("") {
            let error =
                ValidationErrorIsRequired(
                    errorMessage: "required",
                    paymentProductFieldId: identifier,
                    rule: nil
                )
            errors.append(error)
            errorMessageIds.append(error)
        } else if dataRestrictions.isRequired ||
                    !value.isEqual("") ||
                    dataRestrictions.validators.variableRequiredness {
            for rule in dataRestrictions.validators.validators {
                _ = rule.validate(value: value, for: identifier)
                errors.append(contentsOf: rule.errors)
                errorMessageIds.append(contentsOf: rule.errors)
            }
        }

        return errorMessageIds
    }

    public func applyMask(value: String) -> String {
        if let mask = displayHints.mask {
            return stringFormatter.formatString(string: value, mask: mask)
        }

        return value
    }

    public func removeMask(value: String) -> String {
        if let mask = displayHints.mask {
            return stringFormatter.unformatString(string: value, mask: mask)
        }

        return value
    }
}
