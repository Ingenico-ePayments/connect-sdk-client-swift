//
//  ValidatorEmailAddress.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorEmailAddress: Validator {
    public var expression: NSRegularExpression
    
    public override init() {
        let regex = "^[^@\\.]+(\\.[^@\\.]+)*@([^@\\.]+\\.)*[^@\\.]+\\.[^@\\.][^@\\.]+$"
        
        expression = try! NSRegularExpression(pattern: regex)
    }
    
    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)
        
        let numberOfMatches = expression.numberOfMatches(in: value , range: NSMakeRange(0, value.length))
        if numberOfMatches != 1 {
            let error = ValidationErrorEmailAddress()
            errors.append(error)
        }
    }
}
