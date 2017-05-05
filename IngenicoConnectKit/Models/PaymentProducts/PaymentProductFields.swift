//
//  PaymentProductFields.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProductFields {
    
    public var paymentProductFields = [PaymentProductField]()
    
    public func sort() {
        paymentProductFields = paymentProductFields.sorted {
            guard let displayOrder0 = $0.displayHints.displayOrder, let displayOrder1 = $1.displayHints.displayOrder else {
                return false
            }
            return displayOrder0 < displayOrder1
        }
    }
}
