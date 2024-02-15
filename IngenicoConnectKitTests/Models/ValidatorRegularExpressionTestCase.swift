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
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()
        guard let regularExpression = try? NSRegularExpression(pattern: "\\d{3}") else {
            XCTFail("ValidatorRegularExpression setup failed")
            return
        }

        validator = ValidatorRegularExpression(regularExpression: regularExpression)

        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "cardholderName",
                    "type": "string",
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

    func testValidateCorrect() {
        validator.validate(value: "123", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateIncorrect() {
        validator.validate(value: "abc", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

}
