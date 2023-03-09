//
//  DisplayElement.swift
//  Pods
//
//  Created for Ingenico ePayments on 07/07/2017.
//
//

import Foundation

public class DisplayElement: ResponseObjectSerializable {
    public required init?(json: [String: Any]) {
        guard let id = json["id"]  as? String else {
            return nil
        }
        guard let value = json["value"] as? String else {
            return nil
        }
        guard let type = DisplayElementType(rawValue: json["type"] as? String ?? "") else {
            return nil
        }
        self.id = id
        self.value = value
        self.type = type
    }

    public var id: String
    public var type: DisplayElementType
    public var value: String
    init(id: String, type: DisplayElementType, value: String) {
        self.id = id
        self.type = type
        self.value = value
    }
}
