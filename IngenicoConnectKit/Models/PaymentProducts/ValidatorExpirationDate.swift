//
//  ValidatorExpirationDate.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorExpirationDate: Validator, ValidationRule {
    public var dateFormatter = DateFormatter()
    private var fullYearDateFormatter = DateFormatter()
    private var monthAndFullYearDateFormatter = DateFormatter()

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public override init() {
        dateFormatter.dateFormat = "MMyy"
        fullYearDateFormatter.dateFormat = "yyyy"
        monthAndFullYearDateFormatter.dateFormat = "MMyyyy"

        super.init(messageId: "expirationDate", validationType: .expirationDate)
    }

    // periphery:ignore:parameters decoder
    public required init(from decoder: Decoder) throws {
        dateFormatter.dateFormat = "MMyy"
        fullYearDateFormatter.dateFormat = "yyyy"
        monthAndFullYearDateFormatter.dateFormat = "MMyyyy"

        super.init(messageId: "expirationDate", validationType: .expirationDate)
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

        // Test whether the date can be parsed normally
        guard dateFormatter.date(from: value) != nil else {
            addExpirationDateError(fieldId: fieldId)
            return false
        }

        let enteredDate = obtainEnteredDateFromValue(value: value, fieldId: fieldId)

        guard let futureDate = obtainFutureDate() else {
            addExpirationDateError(fieldId: fieldId)
            return false
        }

        if !validateDateIsBetween(now: Date(), futureDate: futureDate, dateToValidate: enteredDate) {
            addExpirationDateError(fieldId: fieldId)
            return false
        }

        return true
    }

    private func addExpirationDateError(fieldId: String?) {
        let error =
            ValidationErrorExpirationDate(
                errorMessage: self.messageId,
                paymentProductFieldId: fieldId,
                rule: self
            )
        errors.append(error)
    }

    internal func obtainEnteredDateFromValue(value: String, fieldId: String?) -> Date {
        let year = fullYearDateFormatter.string(from: Date())
        let valueWithCentury = value.substring(to: 2) + year.substring(to: 2) + value.substring(from: 2)
        guard let dateMonthAndFullYear = monthAndFullYearDateFormatter.date(from: valueWithCentury) else {
            addExpirationDateError(fieldId: fieldId)
            return Date()
        }

        return dateMonthAndFullYear
    }

    private func obtainFutureDate() -> Date? {
        let gregorianCalendar = Calendar(identifier: .gregorian)

        var componentsForFutureDate = DateComponents()
        componentsForFutureDate.year = gregorianCalendar.component(.year, from: Date()) + 25

        return gregorianCalendar.date(from: componentsForFutureDate)
    }

    internal func validateDateIsBetween(now: Date, futureDate: Date, dateToValidate: Date) -> Bool {
        let gregorianCalendar = Calendar(identifier: .gregorian)

        let lowerBoundComparison = gregorianCalendar.compare(now, to: dateToValidate, toGranularity: .month)
        if lowerBoundComparison == ComparisonResult.orderedDescending {
            return false
        }

        let upperBoundComparison = gregorianCalendar.compare(futureDate, to: dateToValidate, toGranularity: .year)
        if upperBoundComparison == ComparisonResult.orderedAscending {
            return false
        }

        return true
    }
}
