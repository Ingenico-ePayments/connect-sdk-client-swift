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

    func testPaymentAmountOfMoneyUnknown() {
        let amount = PaymentAmountOfMoney(totalAmount: 3, currencyCode: "EUR")
        XCTAssertEqual(amount.description, "3-EUR")
    }

}
