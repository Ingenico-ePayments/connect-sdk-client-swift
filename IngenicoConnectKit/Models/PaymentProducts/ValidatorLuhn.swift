//
//  ValidatorLuhn.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorLuhn: Validator {
    
    public override func validate (value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)
        
        var evenSum = 0
        var oddSum = 0
        var digit = 0
        
        for i in 1 ... value.length {
            let j = value.length - i
            digit = Int(value[j])!
            
            if i % 2 == 1 {
                evenSum += digit
            } else {
                digit = digit * 2
                digit = (digit % 10) + (digit / 10)
                oddSum += digit
            }
        }
        
        let total = evenSum + oddSum
        if total % 10 != 0 {
            let error = ValidationErrorLuhn()
            errors.append(error)
        }
    }
    
}
