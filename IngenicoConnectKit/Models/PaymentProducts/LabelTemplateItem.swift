//
//  LabelTemplateItem.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class LabelTemplateItem: ResponseObjectSerializable, Codable {

    public var attributeKey: String
    public var mask: String?

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init?(json: [String: Any]) {
        guard let attributeKey = json["attributeKey"] as? String else {
            return nil
        }
        self.attributeKey = attributeKey

        mask = json["mask"] as? String
    }
}
