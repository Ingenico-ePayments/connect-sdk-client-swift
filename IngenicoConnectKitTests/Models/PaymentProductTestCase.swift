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

    var paymentProduct: PaymentProduct!
    var field: PaymentProductField!

    override func setUp() {
        super.setUp()

        let paymentProductJSON = Data("""
        {
            "fields": [],
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
        self.paymentProduct = paymentProduct

        let fieldJSON = Data("""
        {
            "displayHints": {
                "displayOrder": 1,
                "formElement": {
                    "type": "text"
                }
            },
            "id": "cardNumber",
            "type": "numericstring"
        }
        """.utf8)
        guard let field = try? JSONDecoder().decode(PaymentProductField.self, from: fieldJSON) else {
            XCTFail("Not a valid PaymentProductField")
            return
        }
        self.field = field

        paymentProduct.fields.paymentProductFields.append(field)
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
