//
//  DisplayElementType.swift
//  Pods
//
//  Created for Ingenico ePayments on 22/06/2017.
//
//

import Foundation
public enum DisplayElementType: String, Codable {
    case string = "STRING"
    case integer = "INTEGER"
    case currency = "CURRENCY"
    case percentage = "PERCENTAGE"
    case uri = "URI"
}
