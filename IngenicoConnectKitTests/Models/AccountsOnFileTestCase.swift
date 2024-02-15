//
//  AccountsOnFileTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest

@testable import IngenicoConnectKit

class AccountsOnFileTestCase: XCTestCase {

    let accountsOnFile = AccountsOnFile()
    var account1: AccountOnFile!
    var account2: AccountOnFile!

    override func setUp() {
        super.setUp()

        let account1JSON = Data("""
        {
            "id": 1,
            "paymentProductId": 1
        }
        """.utf8)

        let account2JSON = Data("""
        {
            "id": 2,
            "paymentProductId": 2
        }
        """.utf8)

        guard let account1 = try? JSONDecoder().decode(AccountOnFile.self, from: account1JSON),
              let account2 = try? JSONDecoder().decode(AccountOnFile.self, from: account2JSON) else {
            XCTFail("Accounts are not a valid AccountOnFile")
            return
        }

        self.account1 = account1
        self.account2 = account2

        accountsOnFile.accountsOnFile.append(account1)
        accountsOnFile.accountsOnFile.append(account2)
    }

    func testAccountOnFileWithIdentifier() {
        let testAccount = accountsOnFile.accountOnFile(withIdentifier: "1")

        XCTAssertNotNil(testAccount, "Account could not be found")
        XCTAssert(testAccount! === account1, "Incorrect account on file retrieved")

        for index in 0...3 {
            let templabelJSON = Data("""
            {
                "attributeKey": "attributeKey\(index)",
                "mask": "12345\(index)"
            }
            """.utf8)

            guard let tempItem = try? JSONDecoder().decode(LabelTemplateItem.self, from: templabelJSON) else {
                XCTFail("Not a valid LabelTemplateItem")
                return
            }
            account1.displayHints.labelTemplate.labelTemplateItems.append(tempItem)
        }

        XCTAssertTrue(
            account1.maskedValue(forField: "attributeKey1") == "123451",
            "Mask was: \(account1.maskedValue(forField: "attributeKey1")) should have been: mask1"
        )
        XCTAssertTrue(
            account1.maskedValue(forField: "9999").isEmpty,
            "Mask was: \(account1.maskedValue(forField: "attributeKey1")) should have been nil."
        )

        let attrJSON = Data("""
        {
            "key": "1",
            "status": "READ_ONLY"
        }
        """.utf8)

        let attr2JSON = Data("""
        {
            "key": "2",
            "value": "12345",
            "status": "MUST_WRITE",
            "mustWriteReason": "Must!"
        }
        """.utf8)

        guard let attr = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attrJSON),
              let attr2 = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attr2JSON) else {
            XCTFail("Not all attributes are a valid AccountOnFileAttribute object")
            return
        }

        XCTAssertTrue(!account1.hasValue(forField: "999"), "Should not have value.")

        account1.attributes.attributes.append(attr)
        account1.attributes.attributes.append(attr2)

        XCTAssertTrue(account1.hasValue(forField: attr.key), "Should have value.")

        let foundValue = account1.attributes.value(forField: "2")
        XCTAssertTrue(foundValue == attr2.value, "Values are not equal.")

        XCTAssertTrue(account1.attributes.value(forField: "999").isEmpty, "Value should have been empty.")
    }

    func testAccountsOnFileNotTheSame() {
        XCTAssert(account1.identifier != account2.identifier)
        XCTAssert(account1.paymentProductIdentifier != account2.paymentProductIdentifier)
    }
}
