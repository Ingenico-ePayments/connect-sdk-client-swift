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

    var field: PaymentProductField!
    var request: PaymentRequest!

    override func setUp() {
        super.setUp()

        let fieldJSON = Data("""
        {
            "displayHints": {
                "alwaysShow": false,
                "displayOrder": 10,
                "formElement": {
                    "type": "text"
                },
                "label": "Card number",
                "link": "http://test.com",
                "mask": "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                "obfuscate": false,
                "placeholderLabel": "**** **** **** ****",
                "preferredInputType": "IntegerKeyboard"
            },
            "dataRestrictions": {
               "isRequired": false,
               "validators": {
                  "length": {
                     "minLength": 4,
                     "maxLength": 6
                  },
                  "range": {
                    "minValue": 50,
                    "maxValue": 60
                  }
               }
            },
            "id": "cardNumber",
            "type": "numericstring"
        }
        """.utf8)
        guard let field = try? JSONDecoder().decode(PaymentProductField.self, from: fieldJSON) else {
            XCTFail("Not a valid PaymenProductField")
            return
        }
        self.field = field

        let paymentProductJSON = Data("""
        {
            "fields": [],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/this/is_a_test.png"
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

        field.type = .numericString
        field.validateValue(value: "a", for: request)
        XCTAssertEqual(field.errors.count, 2, "Unexpected number of errors after validation")
    }

    func testPaymentProductField() {
        XCTAssertEqual(field.identifier, "cardNumber")
        XCTAssertEqual(field.type, FieldType.numericString)
        XCTAssertEqual(field.usedForLookup, false)
        XCTAssertEqual(field.dataRestrictions.isRequired, false)
        XCTAssertEqual(field.dataRestrictions.validators.validators.count, 2)
    }

    func testDisplayHints() {
        XCTAssertFalse(field.displayHints.alwaysShow, "Expected alwaysShow to be false")
        XCTAssertEqual(field.displayHints.displayOrder, 10)
        XCTAssertEqual(field.displayHints.formElement.type, FormElementType.textType)
        XCTAssertEqual(field.displayHints.label, "Card number")
        XCTAssertEqual(field.displayHints.link, URL(string: "http://test.com"))
        XCTAssertEqual(field.displayHints.mask, "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}")
        XCTAssertFalse(field.displayHints.obfuscate, "Expected obfuscate to be false")
        XCTAssertEqual(field.displayHints.placeholderLabel, "**** **** **** ****")
        XCTAssertEqual(field.displayHints.preferredInputType, PreferredInputType.integerKeyboard)
    }

    func testApplyMask() {
        XCTAssertEqual(field.applyMask(value: "1111222233334444"), "1111 2222 3333 4444 ")
    }

    func testRemoveMask() {
        XCTAssertEqual(field.removeMask(value: "1111 2222 3333 4444"), "1111222233334444")
    }
}
