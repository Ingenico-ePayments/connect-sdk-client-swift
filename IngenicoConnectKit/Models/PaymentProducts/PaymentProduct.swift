//
//  PaymentProduct.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProduct: BasicPaymentProduct, PaymentItem {

    public var fields: PaymentProductFields = PaymentProductFields()
    public var fieldsWarning: String?

    public required init?(json: [String: Any]) {
        super.init(json: json)

        guard let input = json["fields"] as? [[String: Any]] else {
            return
        }

        for fieldInput in input {
            if let field = PaymentProductField(json: fieldInput) {
                fields.paymentProductFields.append(field)
            }
        }

        fieldsWarning = json["fieldsWarning"] as? String
    }

    public func paymentProductField(withId: String) -> PaymentProductField? {
        for field in fields.paymentProductFields where field.identifier.isEqual(withId) {
            return field
        }
        return nil
    }
}
