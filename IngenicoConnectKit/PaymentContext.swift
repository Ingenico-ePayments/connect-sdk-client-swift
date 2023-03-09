//
//  PaymentContext.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentContext {
    @available(*, deprecated, message: "In the next major release, the type of countryCode will change to String.")
    public var countryCode: CountryCode
    public var countryCodeString: String
    public var locale: String?
    public var forceBasicFlow: Bool?
    public var amountOfMoney: PaymentAmountOfMoney
    public var isRecurring: Bool

    @available(*, deprecated, message: "Use init(PaymentAmountOfMoney:Bool:String:) instead")
    public convenience init(amountOfMoney: PaymentAmountOfMoney, isRecurring: Bool, countryCode: CountryCode) {
        self.init(amountOfMoney: amountOfMoney, isRecurring: isRecurring, countryCode: countryCode.rawValue)
    }

    public init(amountOfMoney: PaymentAmountOfMoney, isRecurring: Bool, countryCode: String) {
        self.amountOfMoney = amountOfMoney
        self.isRecurring = isRecurring
        self.countryCode = CountryCode.init(rawValue: countryCode) ?? .US
        self.countryCodeString = countryCode

        if let languageCode = Locale.current.languageCode {
            self.locale = languageCode.appending("_")
        }
        if let regionCode = Locale.current.regionCode, self.locale != nil {
            self.locale = self.locale!.appending(regionCode)
        }
    }

    public var description: String {
        return "\(amountOfMoney.description)-\(countryCodeString)-\(isRecurring ? "YES" : "NO")"
    }
}
