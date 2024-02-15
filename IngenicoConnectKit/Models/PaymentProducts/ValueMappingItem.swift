//
//  ValueMappingItem.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValueMappingItem: ResponseObjectSerializable, Codable {

    public var displayName: String?
    public var displayElements: [DisplayElement] = []
    public var value: String

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init?(json: [String: Any]) {
        guard let value = json["value"] as? String else {
            return nil
        }
        self.value = value
        if let displayElements = json["displayElements"] as? [[String: Any]] {
            for element in displayElements {
                if let displayElement = DisplayElement(json: element) {
                    self.displayElements.append(displayElement)
                }
            }
        }
        if let displayName = json["displayName"] as? String {
            self.displayName = displayName
            if self.displayElements.filter({ $0.id == "displayName" }).count == 0 && displayName != "" {
                let newElement = DisplayElement(id: "displayName", type: .string, value: displayName)
                self.displayElements.append(newElement)
            }
        } else {
            let displayNames = self.displayElements.filter { $0.id == "displayName" }
            if displayNames.count > 0 {
                self.displayName = displayNames.first?.value
            }
        }
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(String.self, forKey: .value)

        self.displayElements = (try? container.decodeIfPresent([DisplayElement].self, forKey: .displayElements)) ?? []

        if let displayName = try? container.decodeIfPresent(String.self, forKey: .displayName) {
            self.displayName = displayName
            if self.displayElements.filter({ $0.id == "displayName" }).count == 0 && displayName != "" {
                let newElement = DisplayElement(id: "displayName", type: .string, value: displayName)
                self.displayElements.append(newElement)
            }
        } else {
            let displayNames = self.displayElements.filter { $0.id == "displayName" }
            if displayNames.count > 0 {
                self.displayName = displayNames.first?.value
            }
        }
    }
}
