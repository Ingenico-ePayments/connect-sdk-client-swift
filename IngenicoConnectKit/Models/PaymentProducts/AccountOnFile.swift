//
//  AccountOnFile.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class AccountOnFile: ResponseObjectSerializable, Codable {

    public var identifier: String
    public var paymentProductIdentifier: String
    public var displayHints = AccountOnFileDisplayHints()
    public var attributes = AccountOnFileAttributes()
    public var stringFormatter = StringFormatter()

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    public required init?(json: [String: Any]) {

        guard let identifier = json["id"] as? Int,
              let paymentProductId = json["paymentProductId"] as? Int else {
            return nil
        }
        self.identifier = "\(identifier)"
        self.paymentProductIdentifier = "\(paymentProductId)"
        if let input = json["displayHints"] as? [String: Any] {
            if let labelInputs = input["labelTemplate"] as? [[String: Any]] {
                for labelInput in labelInputs {
                    if let label = LabelTemplateItem(json: labelInput) {
                        displayHints.labelTemplate.labelTemplateItems.append(label)
                    }
                }
            }
            displayHints.logo = input["logo"] as? String
        }
        if let input = json["attributes"] as? [[String: Any]] {
            for attributeInput in input {
                if let attribute = AccountOnFileAttribute(json: attributeInput) {
                    attributes.attributes.append(attribute)
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, paymentProductId, displayHints, attributes
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.identifier = "\(idInt)"
        } else {
            self.identifier = try container.decode(String.self, forKey: .id)
        }

        if let paymentProductIdInt = try? container.decode(Int.self, forKey: .paymentProductId) {
            self.paymentProductIdentifier = "\(paymentProductIdInt)"
        } else {
            self.paymentProductIdentifier = try container.decode(String.self, forKey: .paymentProductId)
        }

        if let displayHints = try? container.decodeIfPresent(AccountOnFileDisplayHints.self, forKey: .displayHints) {
            self.displayHints = displayHints
        }

        if let accountOnFileAttributes =
            try? container.decodeIfPresent([AccountOnFileAttribute].self, forKey: .attributes) {
                for accountOnFileAttribute in accountOnFileAttributes {
                    self.attributes.attributes.append(accountOnFileAttribute)
                }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(identifier, forKey: .id)
        try? container.encode(paymentProductIdentifier, forKey: .paymentProductId)
        try? container.encode(displayHints, forKey: .displayHints)
        try? container.encode(attributes.attributes, forKey: .attributes)
    }

    public func maskedValue(forField paymentProductFieldId: String) -> String {
        let mask = displayHints.labelTemplate.mask(forAttributeKey: paymentProductFieldId)
        return maskedValue(forField: paymentProductFieldId, mask: mask)
    }

    public func maskedValue(forField paymentProductFieldId: String, mask: String?) -> String {
        let value = attributes.value(forField: paymentProductFieldId)

        if let mask = mask {
            let relaxedMask = stringFormatter.relaxMask(mask: mask)
            return stringFormatter.formatString(string: value, mask: relaxedMask)
        }

        return value
    }

    public func hasValue(forField paymentProductFieldId: String) -> Bool {
        return attributes.hasValue(forField: paymentProductFieldId)
    }

    public func isReadOnly(field paymentProductFieldId: String) -> Bool {
        return attributes.isReadOnly(field: paymentProductFieldId)
    }

    public var label: String {
        var labelComponents = [String]()

        for labelTemplateItem in displayHints.labelTemplate.labelTemplateItems {
            let value = maskedValue(forField: labelTemplateItem.attributeKey)
            if !value.isEmpty {
                let trimmedValue = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                labelComponents.append(trimmedValue)
            }
        }

        return labelComponents.joined(separator: " ")
    }

}
