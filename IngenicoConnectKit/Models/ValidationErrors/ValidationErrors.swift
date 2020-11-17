//
//  ValidationErrors.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidationError { public init() {} }

public class ValidationErrorAllowed: ValidationError {}
public class ValidationErrorEmailAddress: ValidationError {}
public class ValidationErrorExpirationDate: ValidationError {}
public class ValidationErrorFixedList: ValidationError {}
public class ValidationErrorInteger: ValidationError {}
public class ValidationErrorIsRequired: ValidationError {}
public class ValidationErrorLuhn: ValidationError {}
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

