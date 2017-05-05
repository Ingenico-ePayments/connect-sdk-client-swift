//
//  ValidatorLuhnTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class ValidatorLuhnTestCase: XCTestCase {
    
    let validator = ValidatorLuhn()
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
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testValidateCorrect() {
        validator.validate(value: "4242424242424242", for: request)
        XCTAssert(validator.errors.count == 0, "Valid value considered invalid")
    }
    
    func testValidateIncorrect() {
        validator.validate(value: "1111", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

}
