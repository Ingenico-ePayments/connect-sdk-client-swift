//
//  CustomerDetailsError.swift
//  Pods
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//
//

import Foundation

public class CustomerDetailsError: Error {
    public let responseValues: [[String: Any]]
    init(responseValues: [[String: Any]]) {
        self.responseValues = responseValues
    }
}
