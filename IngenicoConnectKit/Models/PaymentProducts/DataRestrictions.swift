//
//  DataRestrictions.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class DataRestrictions: ResponseObjectSerializable, Codable {

    public var isRequired = false
    public var validators = Validators()

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public init() {}

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init(json: [String: Any]) {
        if let input = json["isRequired"] as? Bool {
            isRequired = input
        }
        if let input = json["validators"] as? [String: Any] {
            self.setValidators(input: input)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case isRequired, validators, validationRules
    }

    private enum ValidationTypeKey: CodingKey {
        case validationType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let isRequired = try? container.decodeIfPresent(Bool.self, forKey: .isRequired) {
            self.isRequired = isRequired
        }
        if let validators = try? container.decodeIfPresent(Validators.self, forKey: .validators) {
            self.validators = validators
        } else if var validatorsContainer = try?
                    container.nestedUnkeyedContainer(forKey: .validationRules) {
            setValidators(validatorsContainer: &validatorsContainer)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(isRequired, forKey: .isRequired)
        try? container.encode(validators.validators, forKey: .validationRules)
    }

    // swiftlint:disable cyclomatic_complexity
    private func setValidators(input: [String: Any]) {
        if input.index(forKey: "luhn") != nil {
            let validator = ValidatorLuhn()
            validators.validators.append(validator)
        }
        if input.index(forKey: "expirationDate") != nil {
            let validator = ValidatorExpirationDate()
            validators.validators.append(validator)
        }
        if let range = input["range"] as? [String: Any] {
            let validator = ValidatorRange(json: range)
            validators.validators.append(validator)
        }
        if let length = input["length"] as? [String: Any] {
            let validator = ValidatorLength(json: length)
            validators.validators.append(validator)
        }
        if let fixedList = input["fixedList"] as? [String: Any] {
            let validator = ValidatorFixedList(json: fixedList)
            validators.validators.append(validator)
        }
        if input.index(forKey: "emailAddress") != nil {
            let validator = ValidatorEmailAddress()
            validators.validators.append(validator)
        }
        if input.index(forKey: "residentIdNumber") != nil {
            let validator = ValidatorResidentIdNumber()
            validators.validators.append(validator)
        }
        if let regularExpression = input["regularExpression"] as? [String: Any],
           let validator = ValidatorRegularExpression(json: regularExpression) {
            validators.validators.append(validator)
        }
        if (input["termsAndConditions"] as? [String: Any]) != nil {
            let validator = ValidatorTermsAndConditions()
            validators.validators.append(validator)
        }
        if (input["iban"] as? [String: Any]) != nil {
            let validator = ValidatorIBAN()
            validators.validators.append(validator)
        }
        if let boletoBancarioRequiredness = input["boletoBancarioRequiredness"] as? [String: Any],
           let validator = ValidatorBoletoBancarioRequiredness(json: boletoBancarioRequiredness) {
            validators.variableRequiredness = true
            validators.validators.append(validator)
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func setValidators(validatorsContainer: inout UnkeyedDecodingContainer) {
        var validatorsArray = validatorsContainer
        while !validatorsContainer.isAtEnd {
            guard let validationRule = try? validatorsContainer.nestedContainer(keyedBy: ValidationTypeKey.self),
                  let type = try? validationRule.decodeIfPresent(ValidationType.self, forKey: .validationType) else {
                return
            }
            let validatorType = getValidatorType(type: type)
            addValidator(validatorType: validatorType, validatorsArray: &validatorsArray)
        }
    }

    private func addValidator<T: Validator>(validatorType: T.Type, validatorsArray: inout UnkeyedDecodingContainer) {
        guard let validator = try? validatorsArray.decode(validatorType.self) else {
            return
        }
        self.validators.validators.append(validator)
    }

    // swiftlint:disable cyclomatic_complexity
    private func getValidatorType(type: ValidationType) -> Validator.Type {
        switch type {
        case .expirationDate:
            return ValidatorExpirationDate.self
        case .emailAddress:
            return ValidatorEmailAddress.self
        case .fixedList:
            return ValidatorFixedList.self
        case .iban:
            return ValidatorIBAN.self
        case .length:
            return ValidatorLength.self
        case .luhn:
            return ValidatorLuhn.self
        case .range:
            return ValidatorRange.self
        case .regularExpression:
            return ValidatorRegularExpression.self
        case .required, .type:
            return Validator.self
        case .boletoBancarioRequiredness:
            return ValidatorBoletoBancarioRequiredness.self
        case .termsAndConditions:
            return ValidatorTermsAndConditions.self
        case .residentIdNumber:
            return ValidatorResidentIdNumber.self
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
