//
//  PaymentProductField.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProductField: ResponseObjectSerializable {
    
    public var identifier: String
    public var dataRestrictions = DataRestrictions()
    public var displayHints: PaymentProductFieldDisplayHints
    public var type: FieldType
    
    public var numberFormatter = NumberFormatter()
    public var numericStringCheck: NSRegularExpression
    
    public var errors: [ValidationError] = []
    
    public required init?(json: [String : Any]) {
        guard let identifier = json["id"] as? String,
              let hints = json["displayHints"] as? [String: Any],
              let displayHints = PaymentProductFieldDisplayHints(json: hints) else
        {
            return nil
        }
        self.identifier = identifier
        self.displayHints = displayHints

        guard let numericStringCheck = try? NSRegularExpression(pattern: "^\\d+$") else {
            return nil
        }
        numberFormatter.numberStyle = .decimal
        self.numericStringCheck = numericStringCheck

        if let input = json["dataRestrictions"] as? [String: Any] {
            dataRestrictions = DataRestrictions(json: input)
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
            default:
                Macros.DLog(message: "Type \(json["type"]!) in JSON fragment \(json) is invalid")
                return nil
        }
    }
    
    public func validateValue(value: String, for request: PaymentRequest) {
        errors.removeAll()
        
        if dataRestrictions.isRequired && value.isEqual("") {
            let error = ValidationErrorIsRequired()
            errors.append(error)
        } else if dataRestrictions.isRequired || !value.isEqual("") || dataRestrictions.validators.variableRequiredness {
            for rule in dataRestrictions.validators.validators {
                rule.validate(value: value, for: request)
                errors.append(contentsOf: rule.errors)
            }
            
            switch type {
                case .integer where numberFormatter.number(from: value) != nil:
                    let error = ValidationErrorInteger()
                    errors.append(error)

                case .numericString where numericStringCheck.numberOfMatches(in: value , range: NSMakeRange(0, value.length)) != 1:
                    let error = ValidationErrorNumericString()
                    errors.append(error)

                default:
                    break
            }
        }
    }
}
