//
//  ValidatorFixedListTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class ValidatorFixedListTestCase: XCTestCase {

    var validator: ValidatorFixedList!
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
        validator = ValidatorFixedList.init(allowedValues: ["1"])
    }

    override func tearDown() {
        super.tearDown()
    }

    func testValidateCorrect() {
        validator.validate(value: "1", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")

        validator.validate(value: "999", for: request)
        XCTAssertEqual(validator.errors.count, 1, "Invalid value considered valid")
    }

    func testValidateIncorrect() {
        validator.validate(value: "X", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

}
