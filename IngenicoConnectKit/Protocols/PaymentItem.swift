//
//  PaymentItem.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public protocol PaymentItem: BasicPaymentItem {
    var fields: PaymentProductFields { get set }
    
    func paymentProductField(withId paymentProductFieldId: String) -> PaymentProductField?
}
