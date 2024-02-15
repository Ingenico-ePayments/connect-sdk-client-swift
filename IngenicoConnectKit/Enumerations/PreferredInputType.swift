//
//  PreferredInputType.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

public enum PreferredInputType: String, Codable {
    case stringKeyboard = "StringKeyboard"
    case integerKeyboard = "IntegerKeyboard"
    case emailAddressKeyboard = "EmailAddressKeyboard"
    case phoneNumberKeyboard = "PhoneNumberKeyboard"
    case dateKeyboard = "DateKeyboard"
    case noKeyboard = "NoKeyboard"
}
