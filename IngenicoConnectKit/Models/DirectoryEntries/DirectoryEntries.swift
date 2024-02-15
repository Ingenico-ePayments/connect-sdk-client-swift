//
//  DirectoryEntries.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class DirectoryEntries: ResponseObjectSerializable, Codable {
    public var directoryEntries: [DirectoryEntry] = []

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public init() {}

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init(json: [String: Any]) {
        if let entries = json["entries"] as? [[String: Any]] {
            for inputEntry in entries {
                if let entry = DirectoryEntry(json: inputEntry) {
                    directoryEntries.append(entry)
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case entries
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.directoryEntries = (try? container.decodeIfPresent([DirectoryEntry].self, forKey: .entries)) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(directoryEntries, forKey: .entries)
    }
}
