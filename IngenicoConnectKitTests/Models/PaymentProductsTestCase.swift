//
//  PaymentProductsTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class PaymentProductsTestCase: XCTestCase {
    
    var products: BasicPaymentProducts!
    var account: AccountOnFile!
    var product1: BasicPaymentProduct!

    override func setUp() {
        super.setUp()
        products = BasicPaymentProducts()

        product1 = BasicPaymentProduct(json: [
            "fields": [[:]],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 100,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ]
        ])

        account = AccountOnFile(json: ["id": 1, "paymentProductId": 1])
        product1?.accountsOnFile.accountsOnFile.append(account)

        let product2 = BasicPaymentProduct(json: [
            "fields": [[:]],
            "id": 2,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 10,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ]
        ])

        let product3 = BasicPaymentProduct(json: [
            "fields": [[:]],
            "id": 3,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 99,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ]
        ])

        if let product1 = product1, let product2 = product2, let product3 = product3 {
            products.paymentProducts.append(product1)
            products.paymentProducts.append(product2)
            products.paymentProducts.append(product3)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testHasAccountsOnFileTrue() {
        XCTAssert(products.hasAccountsOnFile, "Payment products should have an account on file")
    }
    
    func testHasAccountsOnFileFalse() {
        products.paymentProducts.remove(at: 0)
        XCTAssertFalse(products.hasAccountsOnFile, "Payment products should not have an account on file")
    }
    
    func testAccountsOnFile() {
        let accountsOnFile = products.accountsOnFile
        XCTAssertEqual(accountsOnFile.count, 1, "Unexpected number of accounts on file")
        XCTAssert(accountsOnFile[0] === account, "Account on file that was added is not returned")
    }
    
    func testPaymentProductWithIdentifierExisting() {
        XCTAssert(products.paymentProduct(withIdentifier: "1") === product1, "Unexpected payment product retrieved")
    }
    
    func testPaymentProductWithIdentifierNonExisting() {
        XCTAssertNil(products.paymentProduct(withIdentifier: "X"), "Retrieved a payment product that has not been added")
    }
    
    func testSort() {
        products.sort()
        
        var displayOrder = 0
        for i in 0..<3 {
            let product = products.paymentProducts[i]
            if let prodDisplayOrder = product.displayHints.displayOrder, displayOrder > prodDisplayOrder {
                XCTFail("Products are not sorted")
            }
            if let prodDisplayOrder = product.displayHints.displayOrder {
                displayOrder = prodDisplayOrder
            }
        }
    }
}
