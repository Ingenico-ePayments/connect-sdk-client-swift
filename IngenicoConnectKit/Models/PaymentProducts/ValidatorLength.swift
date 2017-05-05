//
//  ValidatorLength.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorLength: Validator, ResponseObjectSerializable {
    public var minLength = 0
    public var maxLength = 0

    public init(minLength: Int?, maxLength: Int?) {
        self.minLength = minLength ?? 0
        self.maxLength = maxLength ?? 0
    }
    
    public required init(json: [String : Any]) {
        if let input = json["maxLength"] as? Int {
            maxLength = input
        }
        if let input = json["minLength"] as? Int {
            minLength = input
        }
    }

    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)
        
        let error = ValidationErrorLength()
        error.minLength = minLength
        error.maxLength = maxLength
        
        if value.length < minLength || value.length > maxLength {
            errors.append(error)
        }
    }
}
