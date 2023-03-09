//
//  PaymentProductFieldDisplayHints.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentProductFieldDisplayHints: ResponseObjectSerializable {

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
            switch input {
            case "StringKeyboard":
                preferredInputType = .stringKeyboard
            case "IntegerKeyboard":
                preferredInputType = .integerKeyboard
            case "EmailAddressKeyboard":
                preferredInputType = .emailAddressKeyboard
            case "PhoneNumberKeyboard":
                preferredInputType = .phoneNumberKeyboard
            case "DateKeyboard":
                preferredInputType = .dateKeyboard
            default:
                break
            }
        }

        if let input = json["tooltip"] as? [String: Any] {
            tooltip = ToolTip(json: input)
        }
    }
}
