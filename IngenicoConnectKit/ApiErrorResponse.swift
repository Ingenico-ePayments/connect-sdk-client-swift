//
//  ApiErrorResponse.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 22/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import Foundation

public class ApiErrorResponse: NSObject, Codable {
    public let errorId: String
    public let errors: [ApiErrorItem]
}
