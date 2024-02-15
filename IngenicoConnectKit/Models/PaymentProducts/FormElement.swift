//
//  FormElement.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class FormElement: ResponseObjectSerializable, Codable {
    public var type: FormElementType
    public var valueMapping = [ValueMappingItem]()

    @available(*, deprecated, message: "In a future release, this initializer will be removed.")
    required public init?(json: [String: Any]) {
        switch json["type"] as? String {
        case "text"?:
            type = .textType
        case "currency"?:
            type = .currencyType
        case "list"?:
            type = .listType
        case "date"?:
            type = .dateType
        case "boolean"?:
            type = .boolType
        default:
            return nil
        }

        if let input = json["valueMapping"] as? [[String: Any]] {
            for valueInput in input {
                if let item = ValueMappingItem(json: valueInput) {
                    valueMapping.append(item)
                }
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, valueMapping
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(FormElementType.self, forKey: .type)

        self.valueMapping =
            (try? container.decodeIfPresent([ValueMappingItem].self, forKey: .valueMapping)) ?? [ValueMappingItem]()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(type.rawValue, forKey: .type)
        try? container.encode(valueMapping, forKey: .valueMapping)
    }
}
