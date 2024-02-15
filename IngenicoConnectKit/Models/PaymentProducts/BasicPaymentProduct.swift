//
//  BasicPaymentProduct.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class BasicPaymentProduct: Equatable, BasicPaymentItem, ResponseObjectSerializable, Codable {

    public var identifier: String
    public var displayHints: PaymentItemDisplayHints
    public var accountsOnFile = AccountsOnFile()
    public var acquirerCountry: String?

    public var allowsTokenization = false
    public var allowsRecurring = false
    public var autoTokenized = false
    public var allowsInstallments = false

    public var authenticationIndicator: AuthenticationIndicator?

    public var deviceFingerprintEnabled = false

    public var minAmount: Int?
    public var maxAmount: Int?

    public var paymentMethod: String
    public var mobileIntegrationLevel: String?
    public var usesRedirectionTo3rdParty = false
    public var paymentProductGroup: String?
    public var supportsMandates = false

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

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public required init?(json: [String: Any]) {
        guard let identifier = json["id"] as? Int,
              let paymentMethod = json["paymentMethod"] as? String,
              let hints = json["displayHints"] as? [String: Any],
              let displayHints = PaymentItemDisplayHints(json: hints)
        else {
            return nil
        }
        if let paymentProduct302SpecificDataDictionary = json["paymentProduct302SpecificData"] as? [String: Any],
            let paymentProduct302SpecificData =
                PaymentProduct302SpecificData(json: paymentProduct302SpecificDataDictionary) {
            self.paymentProduct302SpecificData = paymentProduct302SpecificData
        }
        if let paymentProduct320SpecificDataDictionary = json["paymentProduct320SpecificData"] as? [String: Any],
            let paymentProduct320SpecificData =
                PaymentProduct320SpecificData(json: paymentProduct320SpecificDataDictionary) {
            self.paymentProduct320SpecificData = paymentProduct320SpecificData
        }
        if let paymentProduct863SpecificDataDictionary = json["paymentProduct863SpecificData"] as? [String: Any],
            let paymentProduct863SpecificData =
                PaymentProduct863SpecificData(json: paymentProduct863SpecificDataDictionary) {
            self.paymentProduct863SpecificData = paymentProduct863SpecificData
        }

        self.identifier = "\(identifier)"
        self.paymentMethod = paymentMethod
        self.displayHints = displayHints
        self.acquirerCountry = json["acquirerCountry"] as? String ?? ""

        allowsTokenization = json["allowsTokenization"] as? Bool ?? false
        allowsRecurring = json["allowsRecurring"] as? Bool ?? false
        autoTokenized = json["autoTokenized"] as? Bool ?? false
        allowsInstallments = json["allowsInstallments"] as? Bool ?? false
        authenticationIndicator = json["authenticationIndicator"] as? AuthenticationIndicator

        deviceFingerprintEnabled = json["deviceFingerprintEnabled"] as? Bool ?? false

        minAmount = json["minAmount"] as? Int
        maxAmount = json["maxAmount"] as? Int

        mobileIntegrationLevel = json["mobileIntegrationLevel"] as? String
        usesRedirectionTo3rdParty = json["usesRedirectionTo3rdParty"] as? Bool ?? false
        paymentProductGroup = json["paymentProductGroup"] as? String
        supportsMandates = json["supportsMandates"] as? Bool ?? false

        if let input = json["accountsOnFile"] as? [[String: Any]] {
            for accountInput in input {
                if let account = AccountOnFile(json: accountInput) {
                    accountsOnFile.accountsOnFile.append(account)
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayHints, accountsOnFile, acquirerCountry, allowsTokenization, allowsRecurring, autoTokenized,
             allowsInstallments, authenticationIndicator, deviceFingerprintEnabled, minAmount, maxAmount, paymentMethod,
             mobileIntegrationLevel, usesRedirectionTo3rdParty, paymentProductGroup, supportsMandates,
             paymentProduct302SpecificData, paymentProduct320SpecificData, paymentProduct863SpecificData
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.identifier = "\(idInt)"
        } else {
            self.identifier = try container.decode(String.self, forKey: .id)
        }
        self.paymentMethod = try container.decode(String.self, forKey: .paymentMethod)
        self.displayHints = try container.decode(PaymentItemDisplayHints.self, forKey: .displayHints)

        self.paymentProduct302SpecificData =
            try? container.decodeIfPresent(PaymentProduct302SpecificData.self, forKey: .paymentProduct302SpecificData)
        self.paymentProduct320SpecificData =
            try? container.decodeIfPresent(PaymentProduct320SpecificData.self, forKey: .paymentProduct320SpecificData)
        self.paymentProduct863SpecificData =
            try? container.decodeIfPresent(PaymentProduct863SpecificData.self, forKey: .paymentProduct863SpecificData)

        self.acquirerCountry = try? container.decodeIfPresent(String.self, forKey: .acquirerCountry)
        self.allowsTokenization = (try? container.decodeIfPresent(Bool.self, forKey: .allowsTokenization)) ?? false
        self.allowsRecurring = (try? container.decodeIfPresent(Bool.self, forKey: .allowsRecurring)) ?? false
        self.autoTokenized = (try? container.decodeIfPresent(Bool.self, forKey: .autoTokenized)) ?? false
        self.allowsInstallments = (try? container.decodeIfPresent(Bool.self, forKey: .allowsInstallments)) ?? false
        self.authenticationIndicator =
            try? container.decodeIfPresent(AuthenticationIndicator.self, forKey: .authenticationIndicator)
        self.deviceFingerprintEnabled =
            (try? container.decodeIfPresent(Bool.self, forKey: .deviceFingerprintEnabled)) ?? false

        self.minAmount = try? container.decodeIfPresent(Int.self, forKey: .minAmount)
        self.maxAmount = try? container.decodeIfPresent(Int.self, forKey: .maxAmount)

        self.mobileIntegrationLevel = try? container.decodeIfPresent(String.self, forKey: .mobileIntegrationLevel)
        self.usesRedirectionTo3rdParty =
            (try? container.decodeIfPresent(Bool.self, forKey: .usesRedirectionTo3rdParty)) ?? false
        self.paymentProductGroup = try? container.decodeIfPresent(String.self, forKey: .paymentProductGroup)
        self.supportsMandates = (try? container.decodeIfPresent(Bool.self, forKey: .supportsMandates)) ?? false

        if let accountsOnFile = try? container.decodeIfPresent([AccountOnFile].self, forKey: .accountsOnFile) {
            for accountOnFile in accountsOnFile {
                self.accountsOnFile.accountsOnFile.append(accountOnFile)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(identifier, forKey: .id)
        try? container.encode(paymentMethod, forKey: .paymentMethod)
        try? container.encode(displayHints, forKey: .displayHints)
        try? container.encodeIfPresent(paymentProduct302SpecificData, forKey: .paymentProduct302SpecificData)
        try? container.encodeIfPresent(paymentProduct320SpecificData, forKey: .paymentProduct320SpecificData)
        try? container.encodeIfPresent(paymentProduct863SpecificData, forKey: .paymentProduct863SpecificData)
        try? container.encodeIfPresent(acquirerCountry, forKey: .acquirerCountry)
        try? container.encode(allowsTokenization, forKey: .allowsTokenization)
        try? container.encode(allowsRecurring, forKey: .allowsRecurring)
        try? container.encode(autoTokenized, forKey: .autoTokenized)
        try? container.encode(allowsInstallments, forKey: .allowsInstallments)
        try? container.encodeIfPresent(authenticationIndicator, forKey: .authenticationIndicator)
        try? container.encode(deviceFingerprintEnabled, forKey: .deviceFingerprintEnabled)
        try? container.encodeIfPresent(minAmount, forKey: .minAmount)
        try? container.encodeIfPresent(maxAmount, forKey: .maxAmount)
        try? container.encodeIfPresent(mobileIntegrationLevel, forKey: .mobileIntegrationLevel)
        try? container.encode(usesRedirectionTo3rdParty, forKey: .usesRedirectionTo3rdParty)
        try? container.encodeIfPresent(paymentProductGroup, forKey: .paymentProductGroup)
        try? container.encode(supportsMandates, forKey: .supportsMandates)
        try? container.encode(accountsOnFile.accountsOnFile, forKey: .accountsOnFile)
    }

    public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.accountOnFile(withIdentifier: identifier)
    }

    public static func == (lhs: BasicPaymentProduct, rhs: BasicPaymentProduct) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
