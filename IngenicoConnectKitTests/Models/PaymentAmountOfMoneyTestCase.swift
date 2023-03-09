//
//  PaymentAmountOfMoneyTestCase.swift
//  IngenicoConnectKit
//
//  Created by Fabian Giger on 11-04-17.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class PaymentAmountOfMoneyTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPaymentAmountOfMoneyUnknown() {
        let amount = PaymentAmountOfMoney(totalAmount: 3, currencyCode: "EUR")
        XCTAssertEqual(amount.description, "3-EUR")
    }

}
