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

    var product: BasicPaymentProduct!
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
            XCTFail("Accounts are not both a valid AccountOnFile")
            return
        }
        self.account1 = account1
        self.account2 = account2

        let productJSON = Data("""
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
        guard let product = try? JSONDecoder().decode(BasicPaymentProduct.self, from: productJSON) else {
            XCTFail("Not a valid BasicPaymentProduct")
            return
        }
        self.product = product

        accountsOnFile.accountsOnFile.append(account1)
        accountsOnFile.accountsOnFile.append(account2)
        product.accountsOnFile = accountsOnFile
    }

    func testAccountOnFileWithIdentifier() {
        XCTAssert(product.accountOnFile(withIdentifier: "1") === account1, "Unexpected account on file retrieved")
        XCTAssert(product.accountOnFile(withIdentifier: "2") === account2, "Unexpected account on file retrieved")
    }

    func testSameBasicPaymentProduct() {
        let sameProductJSON = Data("""
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
        guard let sameProduct = try? JSONDecoder().decode(BasicPaymentProduct.self, from: sameProductJSON) else {
            XCTFail("Not a valid BasicPaymentProduct")
            return
        }

        XCTAssertTrue(product == sameProduct)
    }

    func testOtherBasicPaymentProduct() {
        let otherProductJSON = Data("""
        {
            "fields": [],
            "id": 2,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 21,
                "label": "MasterCard",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)
        guard let otherProduct = try? JSONDecoder().decode(BasicPaymentProduct.self, from: otherProductJSON) else {
            XCTFail("Not a valid BasicPaymentProduct")
            return
        }

        XCTAssertFalse(product == otherProduct)
    }
}
