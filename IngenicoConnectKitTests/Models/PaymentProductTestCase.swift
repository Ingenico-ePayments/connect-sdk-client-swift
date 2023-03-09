//
//  PaymentProductTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class PaymentProductTestCase: XCTestCase {

    let paymentProduct = PaymentProduct(json: [
        "fields": [[:]],
        "id": 1,
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
        ]
    ])!
    let field = PaymentProductField(json: [
        "displayHints": [
            "formElement": [
                "type": "text"
            ]
        ],
        "id": "cardNumber",
        "type": "numericstring"
    ])!

    override func setUp() {
        super.setUp()

        paymentProduct.fields.paymentProductFields.append(field)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPaymentProductFieldWithIdExists() {
        let paymentField = paymentProduct.paymentProductField(withId: "cardNumber")
        XCTAssert(field === paymentField, "Retrieved field is unequal to added field")
    }

    func testPaymentProductFieldWithIdNil() {
        let paymentField = paymentProduct.paymentProductField(withId: "X")
        XCTAssertNil(paymentField, "Retrieved a field while no field should be returned")
    }

}
