//
//  Validators.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class Validators: Decodable {
    var variableRequiredness = false

    public var validators = [Validator]()

    internal init() {}

    private enum CodingKeys: String, CodingKey {
        case luhn, expirationDate, range, length, fixedList, emailAddress, residentIdNumber, regularExpression,
             termsAndConditions, iban, boletoBancarioRequiredness
    }

    // swiftlint:disable cyclomatic_complexity
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let validatorLuhn = try? container.decodeIfPresent(ValidatorLuhn.self, forKey: .luhn) {
            self.validators.append(validatorLuhn)
        }
        if let validatorExpirationDate =
            try? container.decodeIfPresent(ValidatorExpirationDate.self, forKey: .expirationDate) {
                self.validators.append(validatorExpirationDate)
        }
        if let validatorRange = try? container.decodeIfPresent(ValidatorRange.self, forKey: .range) {
            self.validators.append(validatorRange)
        }
        if let validatorLength = try? container.decodeIfPresent(ValidatorLength.self, forKey: .length) {
            self.validators.append(validatorLength)
        }
        if let validatorFixedList = try? container.decodeIfPresent(ValidatorFixedList.self, forKey: .fixedList) {
            self.validators.append(validatorFixedList)
        }
        if let validatorEmailAddress =
            try? container.decodeIfPresent(ValidatorEmailAddress.self, forKey: .emailAddress) {
                self.validators.append(validatorEmailAddress)
        }
        if let validatorResidentIdNumber =
            try? container.decodeIfPresent(ValidatorResidentIdNumber.self, forKey: .residentIdNumber) {
                self.validators.append(validatorResidentIdNumber)
        }
        if let validatorRegularExpression =
            try? container.decodeIfPresent(ValidatorRegularExpression.self, forKey: .regularExpression) {
                self.validators.append(validatorRegularExpression)
        }
        if let validatorTermsAndConditions =
            try? container.decodeIfPresent(ValidatorTermsAndConditions.self, forKey: .termsAndConditions) {
                self.validators.append(validatorTermsAndConditions)
        }
        if let validatorIBAN = try? container.decodeIfPresent(ValidatorIBAN.self, forKey: .iban) {
            self.validators.append(validatorIBAN)
        }
        if let validatorBoletoBancarioRequiredness =
            try? container.decodeIfPresent(
                ValidatorBoletoBancarioRequiredness.self,
                forKey: .boletoBancarioRequiredness
            ) {
              self.variableRequiredness = true
              self.validators.append(validatorBoletoBancarioRequiredness)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
