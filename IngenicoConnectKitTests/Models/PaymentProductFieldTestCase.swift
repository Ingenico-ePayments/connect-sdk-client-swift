//
//  PaymentProductFieldTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class PaymentProductFieldTestCase: XCTestCase {
    
    let field = PaymentProductField(json: [
        "displayHints": [
            "formElement": [
                "type": "text"
            ]
        ],
        "id": "cardNumber",
        "type": "numericstring"
    ])!
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
        
        let length = ValidatorLength(minLength: 4, maxLength: 6)
        let range = ValidatorRange(minValue: 50, maxValue: 60)
        field.dataRestrictions.validators.validators.append(length)
        field.dataRestrictions.validators.validators.append(range)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testValidateValueCorrect() {
        field.validateValue(value: "0055", for: request)
        XCTAssertEqual(field.errors.count, 0, "Unexpected errors after validation")
    }
    
    func testValidateValueIncorrect() {
        field.validateValue(value: "0", for: request)
        XCTAssertEqual(field.errors.count, 2, "Unexpected number of errors after validation")
    }
    
    func testTypes() {
        field.dataRestrictions.isRequired = true
        field.validateValue(value: "0055", for: request)
        XCTAssertEqual(field.errors.count, 0, "Unexpected errors after validation")
        
        field.type = .integer
        field.validateValue(value: "0055", for: request)
        XCTAssertEqual(field.errors.count, 1, "Unexpected number of errors after validation")
        
        field.type = .numericString
        field.validateValue(value: "a", for: request)
        XCTAssertEqual(field.errors.count, 3, "Unexpected number of errors after validation")
    }

}
