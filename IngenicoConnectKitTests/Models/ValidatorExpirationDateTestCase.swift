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
        validator.validate(value: "1249", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid expiration date considered invalid")
    }
    
    func testInvalid1() {
        validator.validate(value: "aaaa", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }
    
    func testInvalid2() {
        validator.validate(value: "1350", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }
    
    func testInvalid3() {
        validator.validate(value: "0112", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }
    
    func testInvalid4() {
        validator.validate(value: "1250", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid expiration date considered valid")
    }

}
