//
//  PaymentProductGroup.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProductGroup: PaymentItem, ResponseObjectSerializable {
    
    public var identifier: String
    public var displayHints: PaymentItemDisplayHints
    public var accountsOnFile = AccountsOnFile()
    public var allowsTokenization = false
    public var allowsRecurring = false
    public var autoTokenized = false
    public var fields = PaymentProductFields()

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
    
    public required init?(json: [String : Any]) {

        guard let identifier = json["id"] as? String,
              let hints = json["displayHints"] as? [String : Any],
              let displayHints = PaymentItemDisplayHints(json: hints),
              let fields = json["fields"] as? [[String: Any]] else
        {
            return nil
        }
        self.identifier = identifier
        self.displayHints = displayHints

        if let input = json["accountsOnFile"] as? [[String : Any]] {
            for accountInput in input {
                if let accountFile = AccountOnFile(json: accountInput) {
                    accountsOnFile.accountsOnFile.append(accountFile)
                }
            }
        }

        for field in fields {
            if let paymentProductField = PaymentProductField(json: field) {
                self.fields.paymentProductFields.append(paymentProductField)
            }
        }
    }
    
    public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.accountOnFile(withIdentifier: identifier)
    }
    
    public func paymentProductField(withId paymentProductFieldId: String) -> PaymentProductField? {
        for field in fields.paymentProductFields where field.identifier.isEqual(paymentProductFieldId){
            return field
        }
        return nil
    }
}
