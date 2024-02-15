//
//  PaymentConfiguration.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 24/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

public class PaymentConfiguration: Decodable {
    public let paymentContext: PaymentContext
    public let groupPaymentProducts: Bool

    public init(paymentContext: PaymentContext, groupPaymentProducts: Bool = false) {
        self.paymentContext = paymentContext
        self.groupPaymentProducts = groupPaymentProducts
    }
}
