//
//  BasicPaymentProductGroups.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class BasicPaymentProductGroups: ResponseObjectSerializable, Codable {

    public var paymentProductGroups = [BasicPaymentProductGroup]()

    public var hasAccountsOnFile: Bool {
        for productGroup in paymentProductGroups where productGroup.accountsOnFile.accountsOnFile.count > 0 {
            return true
        }

        return false
    }

    public var accountsOnFile: [AccountOnFile] {
        var accountsOnFile = [AccountOnFile]()

        for productGroup in paymentProductGroups {
            accountsOnFile.append(contentsOf: productGroup.accountsOnFile.accountsOnFile)
        }

        return accountsOnFile
    }

    public var stringFormatter: StringFormatter? {
        get { return paymentProductGroups.first?.stringFormatter }
        set {
            if let stringFormatter = newValue {
                for productGroup in paymentProductGroups {
                    productGroup.stringFormatter = stringFormatter
                }
            }
        }
    }

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public init() {}

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init(json: [String: Any]) {
        if let input = json["paymentProductGroups"] as? [[String: Any]] {
            for groupInput in input {
                if let group = BasicPaymentProductGroup(json: groupInput) {
                    paymentProductGroups.append(group)
                }
            }

            sort()
        }
    }

    enum CodingKeys: CodingKey {
        case paymentProductGroups
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.paymentProductGroups = (
            try? container.decodeIfPresent([BasicPaymentProductGroup].self, forKey: .paymentProductGroups)) ??
                [BasicPaymentProductGroup]()
    }

    public func logoPath(forProductGroup identifier: String) -> String? {
        let productGroup = paymentProductGroup(withIdentifier: identifier)
        return productGroup?.displayHints.logoPath
    }

    public func paymentProductGroup(withIdentifier identifier: String) -> BasicPaymentProductGroup? {
        for productGroup in paymentProductGroups where productGroup.identifier.isEqual(identifier) {
            return productGroup
        }
        return nil
    }

    public func sort() {
        paymentProductGroups = paymentProductGroups.sorted {
            guard let displayOrder0 = $0.displayHints.displayOrder,
                    let displayOrder1 = $1.displayHints.displayOrder else {
                return false
            }
            return displayOrder0 < displayOrder1
        }
    }
}
