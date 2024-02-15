//
//  AccountOnFileAttributeStatus.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

public enum AccountOnFileAttributeStatus: String, Codable {
    case readOnly = "READ_ONLY"
    case canWrite = "CAN_WRITE"
    case mustWrite = "MUST_WRITE"
}
