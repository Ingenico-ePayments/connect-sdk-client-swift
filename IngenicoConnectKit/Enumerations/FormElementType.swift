//
//  FormElementType.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

public enum FormElementType: String, Codable {
    case textType = "text"
    case listType = "list"
    case currencyType = "currency"
    case boolType = "boolean"
    case dateType = "date"
}
