//
//  ValidatorExpirationDate.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorExpirationDate: Validator {
    public var dateFormatter = DateFormatter()
    private var fullYearDateFormatter = DateFormatter()
    private var monthAndFullYearDateFormatter = DateFormatter()

    public override init() {
        dateFormatter.dateFormat = "MMyy"
        fullYearDateFormatter.dateFormat = "yyyy"
        monthAndFullYearDateFormatter.dateFormat = "MMyyyy"
    }

    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)

        // Test whether the date can be parsed normally
        guard dateFormatter.date(from: value) != nil else {
            let error = ValidationErrorExpirationDate()
            errors.append(error)
            return
        }

        let gregorianCalendar = Calendar(identifier: .gregorian)

        guard let enteredDate = obtainEnteredDateFromValue(value: value) else {
            let error = ValidationErrorExpirationDate()
            errors.append(error)
            return
        }

        var componentsForFutureDate = DateComponents()
        componentsForFutureDate.year = gregorianCalendar.component(.year, from: Date()) + 25

        guard let futureDate = gregorianCalendar.date(from: componentsForFutureDate) else {
            let error = ValidationErrorExpirationDate()
            errors.append(error)
            return
        }

        if !validateDateIsBetween(now: Date(), futureDate: futureDate, dateToValidate: enteredDate) {
            let error = ValidationErrorExpirationDate()
            errors.append(error)
        }
    }

    internal func obtainEnteredDateFromValue(value: String) -> Date? {
        let year = fullYearDateFormatter.string(from: Date())
        let valueWithCentury = value.substring(to: 2) + year.substring(to: 2) + value.substring(from: 2)
        guard let dateMonthAndFullYear = monthAndFullYearDateFormatter.date(from: valueWithCentury) else {
            return nil
        }

        return dateMonthAndFullYear
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
