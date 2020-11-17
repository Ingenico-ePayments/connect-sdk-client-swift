//
//  DataRestrictions.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class DataRestrictions: ResponseObjectSerializable {
    
    public var isRequired = false
    public var validators = Validators()
    
    public init() {
    }
    
    required public init(json: [String : Any]) {
        if let input = json["isRequired"] as? Bool {
            isRequired = input
        }
        if let input = json["validators"] as? [String: Any] {
            if let _ = input.index(forKey: "luhn") {
                let validator = ValidatorLuhn()
                validators.validators.append(validator)
            }
            if let _ = input.index(forKey: "expirationDate") {
                let validator = ValidatorExpirationDate()
                validators.validators.append(validator)
            }
            if let range = input["range"] as? [String : Any] {
                let validator = ValidatorRange(json: range)
                validators.validators.append(validator)
            }
            if let length = input["length"] as? [String : Any] {
                let validator = ValidatorLength(json: length)
                validators.validators.append(validator)
            }
            if let fixedList = input["fixedList"] as? [String : Any] {
                let validator = ValidatorFixedList(json: fixedList)
                validators.validators.append(validator)
            }
            if let _ = input.index(forKey: "emailAddress") {
                let validator = ValidatorEmailAddress()
                validators.validators.append(validator)
            }
            if let _ = input.index(forKey: "residentIdNumber") {
                let validator = ValidatorResidentIdNumber()
                validators.validators.append(validator)
            }
            if let regularExpression = input["regularExpression"] as? [String : Any],
                let validator = ValidatorRegularExpression(json: regularExpression) {
                validators.validators.append(validator)
            }
            if ((input["termsAndConditions"] as? [String : Any]) != nil) {
                let validator = ValidatorTermsAndConditions()
                validators.validators.append(validator)
            }
            if ((input["iban"] as? [String : Any]) != nil) {
                let validator = ValidatorIBAN()
                validators.validators.append(validator)
            }
            if let boletoBancarioRequiredness = input["boletoBancarioRequiredness"] as? [String : Any], let validator = ValidatorBoletoBancarioRequiredness(json: boletoBancarioRequiredness) {
                validators.variableRequiredness = true
                validators.validators.append(validator)
            }
        }
    }
    
}
