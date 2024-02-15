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

    let validator = ValidatorFixedList.init(allowedValues: ["1"])
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()

        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "fixedList",
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
