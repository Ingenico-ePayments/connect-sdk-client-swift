//
//  PaymentProductFieldDisplayHints.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProductFieldDisplayHints: ResponseObjectSerializable, Codable {

    public var alwaysShow = false
    public var displayOrder: Int?
    public var formElement: FormElement
    public var mask: String?
    public var obfuscate = false
    public var placeholderLabel: String?
    public var tooltip: ToolTip?
    public var label: String?
    public var link: URL?
    public var preferredInputType: PreferredInputType = .noKeyboard

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init?(json: [String: Any]) {
        guard let input = json["formElement"] as? [String: Any],
              let formElement = FormElement(json: input) else {
            return nil
        }
        self.formElement = formElement

        if let input = json["alwaysShow"] as? Bool {
            alwaysShow = input
        }

        if let input = json["displayOrder"] as? Int {
            displayOrder = input
        }

        if let input = json["mask"] as? String {
            mask = input
        }

        if let input = json["obfuscate"] as? Bool {
            obfuscate = input
        }

        if let input = json["placeholderLabel"] as? String {
            placeholderLabel = input
        }

        if let input = json["label"] as? String {
            label = input
        }

        if let input = json["link"]  as? String {
            link = URL(string: input)
        }

        if let input = json["preferredInputType"] as? String {
            preferredInputType = self.getPreferredInputType(preferredInputType: input)
        }

        if let input = json["tooltip"] as? [String: Any] {
            tooltip = ToolTip(json: input)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case alwaysShow, displayOrder, formElement, mask, obfuscate, placeholderLabel, tooltip, label,
             link, preferredInputType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.formElement = try container.decode(FormElement.self, forKey: .formElement)
        self.alwaysShow = (try? container.decodeIfPresent(Bool.self, forKey: .alwaysShow)) ?? false
        self.displayOrder = try? container.decodeIfPresent(Int.self, forKey: .displayOrder)
        self.mask = try? container.decodeIfPresent(String.self, forKey: .mask)
        self.obfuscate = (try? container.decodeIfPresent(Bool.self, forKey: .obfuscate)) ?? false
        self.placeholderLabel = try? container.decodeIfPresent(String.self, forKey: .placeholderLabel)
        self.label = try? container.decodeIfPresent(String.self, forKey: .label)
        if let linkString = try? container.decodeIfPresent(String.self, forKey: .link) {
            self.link = URL(string: linkString)
        }
        self.preferredInputType =
            (try? container.decodeIfPresent(PreferredInputType.self, forKey: .preferredInputType)) ?? .noKeyboard
        self.tooltip = try? container.decodeIfPresent(ToolTip.self, forKey: .tooltip)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(formElement, forKey: .formElement)
        try? container.encode(alwaysShow, forKey: .alwaysShow)
        try? container.encodeIfPresent(displayOrder, forKey: .displayOrder)
        try? container.encodeIfPresent(mask, forKey: .mask)
        try? container.encode(obfuscate, forKey: .obfuscate)
        try? container.encodeIfPresent(placeholderLabel, forKey: .placeholderLabel)
        try? container.encodeIfPresent(label, forKey: .label)
        try? container.encodeIfPresent(link?.absoluteString, forKey: .link)
        try? container.encode(preferredInputType.rawValue, forKey: .preferredInputType)
        try? container.encodeIfPresent(tooltip, forKey: .tooltip)
    }

    private func getPreferredInputType(preferredInputType: String) -> PreferredInputType {
        switch preferredInputType {
        case "StringKeyboard":
            return .stringKeyboard
        case "IntegerKeyboard":
            return .integerKeyboard
        case "EmailAddressKeyboard":
            return .emailAddressKeyboard
        case "PhoneNumberKeyboard":
            return .phoneNumberKeyboard
        case "DateKeyboard":
            return .dateKeyboard
        default:
            return .noKeyboard
        }
    }
}
