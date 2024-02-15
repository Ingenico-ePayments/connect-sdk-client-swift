//
//  ValidatorEmailAddress.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 09/01/2018.
//  Copyright © 2018 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorTermsAndConditions: Validator, ValidationRule {
    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public override init() {
        super.init(messageId: "termsAndConditions", validationType: .termsAndConditions)
    }

    // periphery:ignore:parameters decoder
    public required init(from decoder: Decoder) throws {
        super.init(messageId: "termsAndConditions", validationType: .termsAndConditions)
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

        if !(Bool(value) ?? false) {
            let error =
                ValidationErrorTermsAndConditions(
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
