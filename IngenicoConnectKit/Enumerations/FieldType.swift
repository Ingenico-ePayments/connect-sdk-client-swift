//
//  Type.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

public enum FieldType: String, Codable {
    case string = "string"
    case integer = "integer"
    case expirationDate = "expirydate"
    case numericString = "numericstring"
    case boolString = "boolean"
    case dateString = "date"
}
