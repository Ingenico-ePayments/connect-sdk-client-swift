//
//  ValidatorRangeTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class ValidatorRangeTestCase: XCTestCase {

    let validator = ValidatorRange(minValue: 40, maxValue: 50)
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()

        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "ccv",
                    "type": "numericstring",
                    "displayHints": {
                        "displayOrder": 0,
                        "formElement": {}
                    }
                }
            ],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)

        guard let paymentProduct = try? JSONDecoder().decode(PaymentProduct.self, from: paymentProductJSON) else {
            XCTFail("Not a valid PaymentProduct")
            return
        }

        request = PaymentRequest(paymentProduct: paymentProduct)
    }

    func testValidateCorrect1() {
        validator.validate(value: "40", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateCorrect2() {
        validator.validate(value: "45", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateCorrect3() {
        validator.validate(value: "50", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateIncorrect1() {
        validator.validate(value: "aaa", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

    func testValidateIncorrect2() {
        validator.validate(value: "39", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

    func testValidateIncorrect3() {
        validator.validate(value: "51", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }
}
