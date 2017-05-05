//
//  BasicPaymentProduct.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class BasicPaymentProduct: Equatable, BasicPaymentItem, ResponseObjectSerializable {
    
    public var identifier: String
    public var displayHints: PaymentItemDisplayHints
    public var accountsOnFile = AccountsOnFile()
    
    public var allowsTokenization = false
    public var allowsRecurring = false
    public var autoTokenized = false
    
    public var paymentMethod: String
    public var paymentProductGroup: String?
    
    public var stringFormatter: StringFormatter? {
        get { return accountsOnFile.accountsOnFile.first?.stringFormatter }
        set {
            if let stringFormatter = newValue {
                for accountOnFile in accountsOnFile.accountsOnFile {
                    accountOnFile.stringFormatter = stringFormatter
                }
            }
        }
    }
    
    public required init?(json: [String: Any]) {
        guard let identifier = json["id"] as? Int,
              let paymentMethod = json["paymentMethod"] as? String,
              let hints = json["displayHints"] as? [String: Any],
              let displayHints = PaymentItemDisplayHints(json: hints)
        else {
            return nil
        }

        self.identifier = "\(identifier)"
        self.paymentMethod = paymentMethod
        self.displayHints = displayHints

        allowsRecurring = json["allowsRecurring"] as? Bool ?? false
        paymentProductGroup = json["paymentProductGroup"] as? String

        if let input = json["accountsOnFile"] as? [[String: Any]] {
            for accountInput in input {
                if let account = AccountOnFile(json: accountInput) {
                    accountsOnFile.accountsOnFile.append(account)
                }
            }
        }
        
        allowsTokenization = json["allowsTokenization"] as? Bool ?? false
    }
    
    public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.accountOnFile(withIdentifier: identifier)
    }
    
    public static func == (lhs: BasicPaymentProduct, rhs: BasicPaymentProduct) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
