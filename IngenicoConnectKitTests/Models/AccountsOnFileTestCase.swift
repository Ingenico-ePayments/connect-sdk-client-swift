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
    let account1 = AccountOnFile(json: ["id": 1, "paymentProductId": 1])!
    let account2 = AccountOnFile(json: ["id": 2, "paymentProductId": 2])!

    override func setUp() {
        super.setUp()
        
        accountsOnFile.accountsOnFile.append(account1)
        accountsOnFile.accountsOnFile.append(account2)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAccountOnFileWithIdentifier() {
        let testAccount = accountsOnFile.accountOnFile(withIdentifier: "1")
        
        XCTAssertNotNil(testAccount, "Account could not be found")
        XCTAssert(testAccount! === account1, "Incorrect account on file retrieved")
        
        account1.displayHints = AccountOnFileDisplayHints()
        account1.displayHints.labelTemplate = LabelTemplate()
        
        for index in 0...3 {
            let tempItem = LabelTemplateItem(json: ["attributeKey": "attributeKey\(index)", "mask": "12345\(index)"])
            account1.displayHints.labelTemplate.labelTemplateItems.append(tempItem!)
        }
        
        XCTAssertTrue(account1.maskedValue(forField: "attributeKey1") == "123451", "Mask was: \(account1.maskedValue(forField: "attributeKey1")) should have been: mask1")
        XCTAssertTrue(account1.maskedValue(forField: "9999").isEmpty, "Mask was: \(account1.maskedValue(forField: "attributeKey1")) should have been nil.")
        
        account1.attributes = AccountOnFileAttributes()
        
        let attr = AccountOnFileAttribute(json: ["key": "1", "status": "READ_ONLY"])!
        let attr2 = AccountOnFileAttribute(json: ["key": "2", "value": "12345", "status": "MUST_WRITE", "mustWriteReason": "Must!"])!
        
        XCTAssertTrue(!account1.hasValue(forField: "999"), "Should not have value.")
        
        account1.attributes.attributes.append(attr)
        account1.attributes.attributes.append(attr2)
        
        XCTAssertTrue(account1.hasValue(forField: attr.key), "Should have value.")
        
        let foundValue = account1.attributes.value(forField: "2")
        XCTAssertTrue(foundValue == attr2.value, "Values are not equal.")
        
        XCTAssertTrue(account1.attributes.value(forField: "999").isEmpty, "Value should have been empty.")
        
    }
    
}
