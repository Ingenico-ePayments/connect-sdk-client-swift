//
//  FormElement.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class FormElement: ResponseObjectSerializable {
    public var type: FormElementType
    public var valueMapping = [ValueMappingItem]()
    
    required public init?(json: [String : Any]) {
        switch json["type"] as? String  {
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
}
