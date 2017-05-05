//
//  BasicPaymentProductTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class BasicPaymentProductTestCase: XCTestCase {
    
    let product = BasicPaymentProduct(json: [
        "fields": [[:]],
        "id": 1,
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
        ]
    ])!
    let accountsOnFile = AccountsOnFile()
    let account1 = AccountOnFile(json: ["id": 1, "paymentProductId": 1])!
    let account2 = AccountOnFile(json: ["id": 2, "paymentProductId": 2])!

    override func setUp() {
        super.setUp()
        
        accountsOnFile.accountsOnFile.append(account1)
        accountsOnFile.accountsOnFile.append(account2)
        product.accountsOnFile = accountsOnFile
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAccountOnFileWithIdentifier() {
        XCTAssert(product.accountOnFile(withIdentifier: "1") === account1, "Unexpected account on file retrieved")
    }

}
