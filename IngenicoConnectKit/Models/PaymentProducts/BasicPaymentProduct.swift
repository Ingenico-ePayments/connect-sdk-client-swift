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
    public var allowsInstallments = false
    
    public var paymentMethod: String
    public var paymentProductGroup: String?
    
    public var paymentProduct302SpecificData: PaymentProduct302SpecificData?
    public var paymentProduct320SpecificData: PaymentProduct320SpecificData?
    public var paymentProduct863SpecificData: PaymentProduct863SpecificData?

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
        if let paymentProduct302SpecificDataDictionary = json["paymentProduct302SpecificData"] as? [String:Any],
            let paymentProduct302SpecificData = PaymentProduct302SpecificData(json:paymentProduct302SpecificDataDictionary) {
            self.paymentProduct302SpecificData = paymentProduct302SpecificData
        }
        if let paymentProduct320SpecificDataDictionary = json["paymentProduct320SpecificData"] as? [String:Any],
            let paymentProduct320SpecificData = PaymentProduct320SpecificData(json:paymentProduct320SpecificDataDictionary){
            self.paymentProduct320SpecificData = paymentProduct320SpecificData
        }
        if let paymentProduct863SpecificDataDictionary = json["paymentProduct863SpecificData"] as? [String:Any],
            let paymentProduct863SpecificData = PaymentProduct863SpecificData(json:paymentProduct863SpecificDataDictionary){
            self.paymentProduct863SpecificData = paymentProduct863SpecificData
        }

        self.identifier = "\(identifier)"
        self.paymentMethod = paymentMethod
        self.displayHints = displayHints

        allowsTokenization = json["allowsTokenization"] as? Bool ?? false
        allowsRecurring = json["allowsRecurring"] as? Bool ?? false
        autoTokenized = json["autoTokenized"] as? Bool ?? false
        allowsInstallments = json["allowsInstallments"] as? Bool ?? false

        paymentProductGroup = json["paymentProductGroup"] as? String

        if let input = json["accountsOnFile"] as? [[String: Any]] {
            for accountInput in input {
                if let account = AccountOnFile(json: accountInput) {
                    accountsOnFile.accountsOnFile.append(account)
                }
            }
        }

    }
    
    public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.accountOnFile(withIdentifier: identifier)
    }
    
    public static func == (lhs: BasicPaymentProduct, rhs: BasicPaymentProduct) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
