//
//  PaymentContext.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentContext {
    public var countryCode: CountryCode
    public var locale: String?
    public var forceBasicFlow: Bool?
    public var amountOfMoney: PaymentAmountOfMoney
    public var isRecurring: Bool
    public init(amountOfMoney: PaymentAmountOfMoney, isRecurring: Bool, countryCode: CountryCode) {      
        self.amountOfMoney = amountOfMoney
        self.isRecurring = isRecurring
        self.countryCode = countryCode
        
        if let languageCode = Locale.current.languageCode {
            self.locale = languageCode.appending("_")
        }
        if let regionCode = Locale.current.regionCode, self.locale != nil {
            self.locale = self.locale!.appending(regionCode)
        }
    }
    
    public var description: String {
        return "\(amountOfMoney.description)-\(countryCode)-\(isRecurring ? "YES" : "NO")"
    }
}
