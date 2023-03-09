//
//  DirectoryEntries.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class DirectoryEntries: ResponseObjectSerializable {
    public var directoryEntries: [DirectoryEntry] = []

    public init() {

    }

    required public init(json: [String: Any]) {
        if let entries = json["entries"] as? [[String: Any]] {
            for inputEntry in entries {
                if let entry = DirectoryEntry(json: inputEntry) {
                    directoryEntries.append(entry)
                }
            }
        }
    }
}
