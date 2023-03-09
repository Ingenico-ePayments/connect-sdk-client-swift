//
//  PaymentAmountOfMoney.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentAmountOfMoney {
    public var totalAmount = 0
    @available(*, deprecated, message: "In the next major release, the type of currencyCode will change to String.")
    public var currencyCode: CurrencyCode
    public var currencyCodeString: String

    @available(*, deprecated, message: "Use init(Int:String) instead")
    public convenience init(totalAmount: Int, currencyCode: CurrencyCode) {
        self.init(totalAmount: totalAmount, currencyCode: currencyCode.rawValue)
    }

    public init(totalAmount: Int, currencyCode: String) {
        self.totalAmount = totalAmount
        self.currencyCode = CurrencyCode.init(rawValue: currencyCode) ?? .USD
        self.currencyCodeString = currencyCode
    }

    public var description: String {
        return "\(totalAmount)-\(currencyCodeString)"
    }

}
