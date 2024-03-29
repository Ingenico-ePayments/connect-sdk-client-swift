//
//  ValidatorResidentIdNumberTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 7/10/2020.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class ValidatorResidentIdNumberTestCase: XCTestCase {

    let validator = ValidatorResidentIdNumber()
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()

        let paymentProductJSON = Data("""
        {
            "fields": [
                {
                    "id": "residentIdNumber",
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

    // - MARK: Valid ID Tests

    func testValidate15CharacterId() {
        validator.validate(value: "123456789101112", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidate18CharacterId() {
        validator.validate(value: "110101202009235416", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    func testValidateIdEndingInX() {
        validator.validate(value: "11010120200922993X", for: request)
        XCTAssertEqual(validator.errors.count, 0, "Valid value considered invalid")
    }

    // - MARK: Invalid ID Tests

    func test16CharacterId() {
        validator.validate(value: "1234567890123451", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

    func test17CharacterId() {
        validator.validate(value: "1234567890123451X", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

    func testValidateTooShortId() {
        validator.validate(value: "1", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

    func testValidateTooLongId() {
        validator.validate(value: "110101202009224733110101202009224733", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }

    func testValidateInvalidChecksum() {
        validator.validate(value: "110101202009224734", for: request)
        XCTAssertNotEqual(validator.errors.count, 0, "Invalid value considered valid")
    }
}
