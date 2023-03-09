//
//  DirectoryEntry.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class DirectoryEntry: ResponseObjectSerializable {
    public var issuerIdentifier: String
    public var issuerList: String
    public var issuerName: String
    public var countryNames: [String] = []

    public required init?(json: [String: Any]) {
        if let input = json["issuerId"] as? String {
            issuerIdentifier = input
        } else {
            return nil
        }
        if let input = json["issuerList"] as? String {
            issuerList = input
        } else {
            return nil
        }
        if let input = json["issuerName"] as? String {
            issuerName = input
        } else {
            return nil
        }

        if let input = json["countryNames"] as? [String] {
            for countryInput in input {
                countryNames.append(countryInput)
            }
        }
    }
}
