//
//  ValidatorRegularExpressionTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class ValidatorRegularExpressionTestCase: XCTestCase {

    var validator: ValidatorRegularExpression!
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
        guard let regularExpression = try? NSRegularExpression(pattern: "\\d{3}") else {
            XCTFail("ValidatorRegularExpression setup failed")
            return
        }

        validator = ValidatorRegularExpression(regularExpression: regularExpression)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testValidateCorrect() {
        validator.validate(value: "123", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateIncorrect() {
        validator.validate(value: "abc", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

}
