//
//  DisplayElement.swift
//  Pods
//
//  Created for Ingenico ePayments on 22/06/2017.
//
//

import UIKit

public class DisplayElement: ResponseObjectSerializable {
    let id: String
    let type: DisplayElementType
    let value: String
    init(id: String, type: DisplayElementType, value: String) {
        self.id = id
        self.type = type
        self.value = value
    }
    required public init?(json: [String: Any]) {
        if let id = json["id"] as? String {
            self.id = id
        }
        else {
            return nil
        }
        
        if let typeString = json["type"] as? String, let type = DisplayElementType(rawValue: typeString) {
            self.type = type
        }
        else {
            return nil
        }
        if let value = json["value"] as? String {
            self.value = value
        }
        else {
            return nil
        }
    }

}
