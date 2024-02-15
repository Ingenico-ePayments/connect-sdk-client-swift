//
//  BasicPaymentItem.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public protocol BasicPaymentItem: Encodable {
    var identifier: String { get set }
    var displayHints: PaymentItemDisplayHints { get set }
    var accountsOnFile: AccountsOnFile { get set }
    var acquirerCountry: String? { get set }
}
