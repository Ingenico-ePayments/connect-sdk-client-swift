//
//  PaymentAmountOfMoney.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentAmountOfMoney: Decodable {
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

    enum CodingKeys: CodingKey {
        case amount, currencyCode
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.totalAmount = try container.decode(Int.self, forKey: .amount)

        if let currencyCodeString = try? container.decodeIfPresent(String.self, forKey: .currencyCode) {
            self.currencyCodeString = currencyCodeString
            self.currencyCode = CurrencyCode.init(rawValue: currencyCodeString) ?? .USD
        } else {
            self.currencyCodeString = "USD"
            self.currencyCode = .USD
        }
    }

    public var description: String {
        return "\(totalAmount)-\(currencyCodeString)"
    }

}
