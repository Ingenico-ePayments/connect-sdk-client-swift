//
//  ValidationErrors.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidationError: Codable {
    public var errorMessage: String = ""
    public var paymentProductFieldId: String?
    public var rule: Validator?

    public init() {}

    public init(errorMessage: String, paymentProductFieldId: String?, rule: Validator?) {
        self.errorMessage = errorMessage
        self.paymentProductFieldId = paymentProductFieldId
        self.rule = rule
    }
}

public class ValidationErrorAllowed: ValidationError {}
public class ValidationErrorEmailAddress: ValidationError {}
public class ValidationErrorExpirationDate: ValidationError {}
public class ValidationErrorFixedList: ValidationError {}
@available(*, deprecated, message: "In a future release, this class will be removed.")
public class ValidationErrorInteger: ValidationError {}
public class ValidationErrorIsRequired: ValidationError {}
public class ValidationErrorLuhn: ValidationError {}
@available(*, deprecated, message: "In a future release, this class will be removed.")
public class ValidationErrorNumericString: ValidationError {}
public class ValidationErrorRegularExpression: ValidationError {}
public class ValidationErrorTermsAndConditions: ValidationError {}
public class ValidationErrorIBAN: ValidationError {}
public class ValidationErrorResidentId: ValidationError {}

public class ValidationErrorLength: ValidationError {

    public var minLength = 0
    public var maxLength = 0
}

public class ValidationErrorRange: ValidationError {

    public var minValue = 0
    public var maxValue = 0
}

public class ValidationErrorInvalidPaymentProduct: ValidationError {}
