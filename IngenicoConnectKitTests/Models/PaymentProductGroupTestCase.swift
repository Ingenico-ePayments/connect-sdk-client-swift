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

    var group: PaymentProductGroup!

    override func setUp() {
        super.setUp()

        let groupJSON = Data("""
        {
            "fields": [],
            "id": "1",
            "paymentMethod": "card",
            "deviceFingerprintEnabled": true,
            "allowsInstallments": false,
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            }
        }
        """.utf8)
        guard let group = try? JSONDecoder().decode(PaymentProductGroup.self, from: groupJSON) else {
            XCTFail("Not a valid PaymentProductGroup")
            return
        }
        self.group = group

        for index in 1..<6 {
            let accountOnFileJSON = Data("""
            {
                "id": \(index),
                "paymentProductId": \(index)
            }
            """.utf8)

            guard let accountOnFile = try? JSONDecoder().decode(AccountOnFile.self, from: accountOnFileJSON) else {
                XCTFail("Not a valid AccountOnFile")
                return
            }

            group.accountsOnFile.accountsOnFile.append(accountOnFile)
        }
    }

    func testPaymentProductGroupValues() {
        XCTAssertEqual(group.identifier, "1")
        XCTAssertEqual(group.displayHints.displayOrder, 20)
        XCTAssertEqual(group.displayHints.label, "Visa")
        XCTAssertEqual(group.displayHints.logoPath, "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png")
        XCTAssertTrue(group.deviceFingerprintEnabled)
        XCTAssertFalse(group.allowsInstallments)
        XCTAssertEqual(group.accountsOnFile.accountsOnFile[0].identifier, "1")
        XCTAssertEqual(group.accountsOnFile.accountsOnFile[0].paymentProductIdentifier, "1")
        XCTAssertEqual(group.fields.paymentProductFields.count, 0)
    }

    func testBasicPaymentProductGroupHasAccountOnFile() {

        let account = group.accountOnFile(withIdentifier: "1")
        XCTAssertTrue(account != nil, "Account on file identifier didn't match.")

        let notFoundAccount = group.accountOnFile(withIdentifier: "9999")
        XCTAssertTrue(notFoundAccount == nil, "Account on file identifier didn't match.")

    }

    func testPaymentField() {
        let field1JSON = Data("""
        {
            "displayHints": {
                "displayOrder": 1,
                "formElement": {
                    "type": "text"
                }
            },
            "id": "1",
            "type": "numericstring"
        }
        """.utf8)
        guard let field1 = try? JSONDecoder().decode(PaymentProductField.self, from: field1JSON) else {
            XCTFail("Not a valid PaymentProductField")
            return
        }
        group.fields.paymentProductFields.append(field1)

        let field2JSON = Data("""
        {
            "displayHints": {
                "displayOrder": 2,
                "formElement": {
                    "type": "text"
                }
            },
            "id": "2",
            "type": "numericstring"
        }
        """.utf8)
        guard let field2 = try? JSONDecoder().decode(PaymentProductField.self, from: field2JSON) else {
            XCTFail("Not a valid PaymentProductField")
            return
        }
        group.fields.paymentProductFields.append(field2)

        let foundField = group.paymentProductField(withId: "1")
        XCTAssertTrue(foundField?.identifier == field1.identifier, "Did not find the correct PaymentProductField.")

        let emptyField = group.paymentProductField(withId: "9999")
        XCTAssertTrue(emptyField == nil, "Should not have found a PaymentProductField.")
    }
}
