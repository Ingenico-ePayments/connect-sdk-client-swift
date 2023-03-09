//
//  ValidatorExpirationDateTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class ValidatorExpirationDateTestCase: XCTestCase {

    var validator: ValidatorExpirationDate!
    let request = PaymentRequest(paymentProduct: PaymentProduct(json: [
        "fields": [[:]],
        "id": 1,
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/this/is_a_test.png"
        ]
    ])!)

    override func setUp() {
        super.setUp()
        validator = ValidatorExpirationDate()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testValid() {
        validator.validate(value: "1244", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid expiration date considered invalid")
    }

    func testInvalidNonNumerical() {
        validator.validate(value: "aaaa", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }

    func testInvalidMonth() {
        validator.validate(value: "1350", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }

    func testInvalidYearTooEarly() {
        validator.validate(value: "0112", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }

    func testInvalidYearTooLate() {
        validator.validate(value: "1299", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }

    func testInvalidInputTooLong() {
        validator.validate(value: "122044", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }

    private var now: Date {
        var components = DateComponents()
        components.year = 2018
        components.month = 9
        components.day = 23
        components.hour = 6
        components.minute = 33
        components.second = 37
        return Calendar.current.date(from: components)!
    }

    private var futureDate: Date {
        var components = DateComponents()
        components.year = 2033
        components.month = 9
        components.day = 23
        components.hour = 6
        components.minute = 33
        components.second = 37
        return Calendar.current.date(from: components)!
    }

    func testValidLowerSameMonthAndYear() {
        var components = DateComponents()
        components.year = 2018
        components.month = 9
        let testDate = Calendar.current.date(from: components)!

        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testInValidLowerMonth() {
        var components = DateComponents()
        components.year = 2018
        components.month = 8
        let testDate = Calendar.current.date(from: components)!

        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testInValidLowerYear() {
        var components = DateComponents()
        components.year = 2017
        components.month = 9
        let testDate = Calendar.current.date(from: components)!

        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testValidUpperSameMonthAndYear() {
        var components = DateComponents()
        components.year = 2033
        components.month = 9
        let testDate = Calendar.current.date(from: components)!

        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testValidUpperHigherMonthSameYear() {
        var components = DateComponents()
        components.year = 2033
        components.month = 11
        let testDate = Calendar.current.date(from: components)!

        XCTAssertTrue(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testInValidUpperHigherYear() {
        var components = DateComponents()
        components.year = 2034
        components.month = 1
        let testDate = Calendar.current.date(from: components)!

        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }

    func testInValidUpperMuchHigherYear() {
        var components = DateComponents()
        components.year = 2099
        components.month = 1
        let testDate = Calendar.current.date(from: components)!

        XCTAssertFalse(validator.validateDateIsBetween(now: now, futureDate: futureDate, dateToValidate: testDate))
    }
}
