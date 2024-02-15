//
//  PaymentProductGroup.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProductGroup: BasicPaymentProductGroup, PaymentItem {

    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed since it is not returned from the API."
    )
    public var allowsTokenization = false
    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed since it is not returned from the API."
    )
    public var allowsRecurring = false
    @available(
        *,
        deprecated,
         message: "In a future release, this property will be removed since it is not returned from the API."
    )
    public var autoTokenized = false
    public var fields = PaymentProductFields()

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public required init?(json: [String: Any]) {

        super.init(json: json)

        guard let fields = json["fields"] as? [[String: Any]] else {
            return nil
        }

        for field in fields {
            if let paymentProductField = PaymentProductField(json: field) {
                self.fields.paymentProductFields.append(paymentProductField)
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case fields
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let fieldsInput = try? container.decodeIfPresent([PaymentProductField].self, forKey: .fields) {
            for field in fieldsInput {
                self.fields.paymentProductFields.append(field)
            }
        }

        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(fields.paymentProductFields, forKey: .fields)

        try super.encode(to: encoder)
    }

    public func paymentProductField(withId paymentProductFieldId: String) -> PaymentProductField? {
        for field in fields.paymentProductFields where field.identifier.isEqual(paymentProductFieldId) {
            return field
        }
        return nil
    }
}
