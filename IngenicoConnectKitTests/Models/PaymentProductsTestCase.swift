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
    var product1: BasicPaymentProduct!

    override func setUp() {
        super.setUp()
        products = BasicPaymentProducts()

        let product1JSON = Data("""
        {
            "fields": [],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 100,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false,
            "accountsOnFile": [{
                "id": 1,
                "paymentProductId": 1
            }]
        }
        """.utf8)
        product1 = try? JSONDecoder().decode(BasicPaymentProduct.self, from: product1JSON)

        let product2JSON = Data("""
        {
            "fields": [],
            "id": 2,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 10,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)
        let product2 = try? JSONDecoder().decode(BasicPaymentProduct.self, from: product2JSON)

        let product3JSON = Data("""
        {
            "fields": [],
            "id": 3,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 99,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)
        let product3 = try? JSONDecoder().decode(BasicPaymentProduct.self, from: product3JSON)

        guard let product1,
              let product2,
              let product3 else {
            XCTFail("Not all products are a valid BasicPaymentProduct")
            return
        }

        products.paymentProducts.append(product1)
        products.paymentProducts.append(product2)
        products.paymentProducts.append(product3)
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
    }

    func testPaymentProductWithIdentifierExisting() {
        XCTAssert(products.paymentProduct(withIdentifier: "1") === product1, "Unexpected payment product retrieved")
    }

    func testPaymentProductWithIdentifierNonExisting() {
        XCTAssertNil(
            products.paymentProduct(withIdentifier: "X"),
            "Retrieved a payment product that has not been added"
        )
    }

    func testSort() {
        products.sort()

        var displayOrder = 0
        for index in 0..<3 {
            let product = products.paymentProducts[index]
            if let prodDisplayOrder = product.displayHints.displayOrder, displayOrder > prodDisplayOrder {
                XCTFail("Products are not sorted")
            }
            if let prodDisplayOrder = product.displayHints.displayOrder {
                displayOrder = prodDisplayOrder
            }
        }
    }
}
