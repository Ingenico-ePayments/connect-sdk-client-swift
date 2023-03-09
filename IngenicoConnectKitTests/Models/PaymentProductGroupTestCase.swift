//
//  PaymentProductGroupTestCase.swift
//  IngenicoConnectKit
//
//  Created by Fabian Giger on 03-04-17.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

import XCTest

@testable import IngenicoConnectKit

class PaymentProductGroupTestCase: XCTestCase {

    let group = PaymentProductGroup(json: [
        "fields": [[:]],
        "id": "1",
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
        ]
    ])!

    override func setUp() {
        super.setUp()

        for index in 1..<6 {
            let accountOnFile = AccountOnFile(json: ["id": index, "paymentProductId": index])!
            group.accountsOnFile.accountsOnFile.append(accountOnFile)
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicPaymentProductGroupHasAccountOnFile() {

        let account = group.accountOnFile(withIdentifier: "1")
        XCTAssertTrue(account != nil, "Account on file identifier didn't match.")

        let notFoundAccount = group.accountOnFile(withIdentifier: "9999")
        XCTAssertTrue(notFoundAccount == nil, "Account on file identifier didn't match.")

    }

    func testPaymentField() {
        let field = PaymentProductField(json: [
            "displayHints": [
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": "1",
            "type": "numericstring"
        ])!
        group.fields.paymentProductFields.append(field)

        let field1 = PaymentProductField(json: [
            "displayHints": [
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": "2",
            "type": "numericstring"
        ])!
        group.fields.paymentProductFields.append(field1)

        let foundField = group.paymentProductField(withId: "1")
        XCTAssertTrue(foundField?.identifier == field.identifier, "Did not find the correct PaymentProductField.")

        let emptyField = group.paymentProductField(withId: "9999")
        XCTAssertTrue(emptyField == nil, "Should not have found a PaymentProductField.")

    }
}
