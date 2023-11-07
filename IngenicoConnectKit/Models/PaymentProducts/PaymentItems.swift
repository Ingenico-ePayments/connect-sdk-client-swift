//
//  PaymentItems.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentItems {

    public var paymentItems = [BasicPaymentItem]()
    public var stringFormatter: StringFormatter?
    public var allPaymentItems = [BasicPaymentItem]()

    public var hasAccountsOnFile: Bool {
        for paymentItem in paymentItems where paymentItem.accountsOnFile.accountsOnFile.count > 0 {
            return true
        }
        return false
    }

    public var accountsOnFile: [AccountOnFile] {
        var accountsOnFile = [AccountOnFile]()

        for paymentItem in paymentItems {
            accountsOnFile.append(contentsOf: paymentItem.accountsOnFile.accountsOnFile)
        }

        return accountsOnFile
    }

    public init(products: BasicPaymentProducts, groups: BasicPaymentProductGroups?) {
        paymentItems = createPaymentItemsFromProducts(products: products, groups: groups)

        allPaymentItems = products.paymentProducts
        if let groups = groups {
            for group in groups.paymentProductGroups {
                allPaymentItems.append(group)
            }
        }
    }

    public func createPaymentItemsFromProducts(
        products: BasicPaymentProducts,
        groups: BasicPaymentProductGroups?
    ) -> [BasicPaymentItem] {
        var paymentItems = [BasicPaymentItem]()

        for product in products.paymentProducts {
            var groupMatch = false

            if let groups = groups, let productGroup = product.paymentProductGroup {
                for group in groups.paymentProductGroups {
                    if productGroup.isEqual(group.identifier) &&
                       !paymentItems.contains(where: { $0.identifier == group.identifier }) {
                        group.displayHints.displayOrder = group.displayHints.displayOrder
                        paymentItems.append(group)
                    }

                    groupMatch = true
                    break
                }
            }

            if !groupMatch {
                paymentItems.append(product)
            }
        }

        return paymentItems
    }

    public func logoPath(forItem identifier: String) -> String? {
        guard let item = paymentItem(withIdentifier: identifier) else {
            return nil
        }

        return item.displayHints.logoPath
    }

    public func paymentItem(withIdentifier identifier: String) -> BasicPaymentItem? {
        for paymentItem in allPaymentItems where paymentItem.identifier.isEqual(identifier) {
            return paymentItem
        }

        return nil
    }

    public func sort() {
        paymentItems = paymentItems.sorted {
            guard let displayOrder0 = $0.displayHints.displayOrder,
                  let displayOrder1 = $1.displayHints.displayOrder else {
                return false
            }
            return displayOrder0 < displayOrder1
        }
    }
}
