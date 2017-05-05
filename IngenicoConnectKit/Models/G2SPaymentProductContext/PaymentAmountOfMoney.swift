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
    public var currencyCode: CurrencyCode
    
    public init(totalAmount: Int, currencyCode: CurrencyCode) {
        self.totalAmount = totalAmount
        self.currencyCode = currencyCode
    }
    
    public var description: String {
        return "\(totalAmount)-\(currencyCode)"
    }
    
    
}
