//
//  ApiErrorItem.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 22/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

public class ApiErrorItem: NSObject, Codable {
    public let category: String?
    public let code: String
    public let httpStatusCode: Int
    public let id: String?
    public let message: String
    public let propertyName: String?
    public let requestId: String?
}
