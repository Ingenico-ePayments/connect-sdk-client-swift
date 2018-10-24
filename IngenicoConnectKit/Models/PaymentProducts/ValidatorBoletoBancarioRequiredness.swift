//
//  ValidatorBoletoBancarioRequiredness.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

public class ValidatorBoletoBancarioRequiredness: Validator {
    public var fiscalNumberLength: Int

    required public init?(json: [String : Any]) {
        guard let input = json["fiscalNumberLength"] as? Int else {
            return nil
        }
        fiscalNumberLength = input
    }

    override public func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        if let fiscalNumber = request.unmaskedValue(forField: "fiscalNumber"),
           fiscalNumber.count == fiscalNumberLength && value.isEmpty {
            let error = ValidationErrorIsRequired()
            errors.append(error)
        }
    }
}
