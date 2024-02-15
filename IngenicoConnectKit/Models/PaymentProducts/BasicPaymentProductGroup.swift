//
//  BasicPaymentProductGroup.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class BasicPaymentProductGroup: ResponseObjectSerializable, BasicPaymentItem, Codable {

    public var identifier: String
    public var displayHints: PaymentItemDisplayHints
    public var accountsOnFile = AccountsOnFile()
    @available(
        *,
        deprecated,
        message: "In a future release, this property will be removed since it is not returned from the API."
    )
    public var acquirerCountry: String?
    public var deviceFingerprintEnabled = false
    public var allowsInstallments = false

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
        guard let identifier = json["id"] as? String,
            let hints = json["displayHints"] as? [String: Any],
            let displayHints = PaymentItemDisplayHints(json: hints) else {
            return nil
        }
        self.identifier = identifier
        self.displayHints = displayHints
        self.deviceFingerprintEnabled = json["deviceFingerprintEnabled"] as? Bool ?? false
        self.allowsInstallments = json["allowsInstallments"] as? Bool ?? false

        if let input = json["accountsOnFile"] as? [[String: Any]] {
            for accountInput in input {
                if let account = AccountOnFile(json: accountInput) {
                    accountsOnFile.accountsOnFile.append(account)
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, displayHints, deviceFingerprintEnabled, allowsInstallments, accountsOnFile
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .id)
        self.displayHints = try container.decode(PaymentItemDisplayHints.self, forKey: .displayHints)
        self.deviceFingerprintEnabled =
            (try container.decodeIfPresent(Bool.self, forKey: .deviceFingerprintEnabled)) ?? false
        self.allowsInstallments = (try container.decodeIfPresent(Bool.self, forKey: .allowsInstallments)) ?? false

        if let accountsOnFile = try? container.decodeIfPresent([AccountOnFile].self, forKey: .accountsOnFile) {
            for accountOnFile in accountsOnFile {
                self.accountsOnFile.accountsOnFile.append(accountOnFile)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(identifier, forKey: .id)
        try? container.encode(displayHints, forKey: .displayHints)
        try? container.encode(deviceFingerprintEnabled, forKey: .deviceFingerprintEnabled)
        try? container.encode(allowsInstallments, forKey: .allowsInstallments)
        try? container.encode(accountsOnFile.accountsOnFile, forKey: .accountsOnFile)
    }

    public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        return accountsOnFile.accountOnFile(withIdentifier: identifier)
    }
}
