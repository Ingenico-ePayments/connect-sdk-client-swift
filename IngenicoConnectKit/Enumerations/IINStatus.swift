//
//  IINStatus.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

public enum IINStatus {
    case supported
    case unsupported
    case unknown
    case notEnoughDigits
    case pending
    case existingButNotAllowed
}
