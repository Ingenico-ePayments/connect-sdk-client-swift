//
//  IINStatus.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

public enum IINStatus: String, Codable {
    case supported = "SUPPORTED"
    case unsupported = "UNSUPPORTED"
    case unknown = "UNKNOWN"
    case notEnoughDigits = "NOT_ENOUGH_DIGITS"
    case pending = "PENDING"
    case existingButNotAllowed = "EXISTING_BUT_NOT_ALLOWED"
}
