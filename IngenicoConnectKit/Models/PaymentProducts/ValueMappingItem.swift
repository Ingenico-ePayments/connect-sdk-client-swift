//
//  ValueMappingItem.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValueMappingItem: ResponseObjectSerializable {
    
    public var displayName: String?
    public var value: String
    
    required public init?(json: [String : Any]) {
        guard let value = json["value"] as? String else {
            return nil
        }
        self.value = value

        displayName = json["displayName"] as? String
    }
}
