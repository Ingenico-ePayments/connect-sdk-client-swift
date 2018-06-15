//
//  AccountOnFile.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class AccountOnFile: ResponseObjectSerializable {
    
    public var identifier: String
    public var paymentProductIdentifier: String
    public var displayHints = AccountOnFileDisplayHints()
    public var attributes = AccountOnFileAttributes()
    public var stringFormatter = StringFormatter()
    
    public required init?(json: [String: Any]) {
        
        guard let identifier = json["id"] as? Int,
              let paymentProductId = json["paymentProductId"] as? Int else
        {
            return nil
        }
        self.identifier = "\(identifier)"
        self.paymentProductIdentifier = "\(paymentProductId)"
        if let input = json["displayHints"] as? [String: Any] {
            if let labelInputs = input["labelTemplate"] as? [[String:Any]] {
                for labelInput in labelInputs {
                    if let label = LabelTemplateItem(json: labelInput) {
                        displayHints.labelTemplate.labelTemplateItems.append(label)
                    }
                }
            }
        }
        if let input = json["attributes"] as? [[String: Any]] {
            for attributeInput in input {
                if let attribute = AccountOnFileAttribute(json: attributeInput) {
                    attributes.attributes.append(attribute)
                }
            }
        }
    }
    
    
    public func maskedValue(forField paymentProductFieldId: String) -> String {
        let mask = displayHints.labelTemplate.mask(forAttributeKey: paymentProductFieldId)
        return maskedValue(forField: paymentProductFieldId, mask: mask)
    }
    
    public func maskedValue(forField paymentProductFieldId: String, mask: String?) -> String {
        let value = attributes.value(forField: paymentProductFieldId)
        
        if let mask = mask {
            let relaxedMask = stringFormatter.relaxMask(mask: mask)
            return stringFormatter.formatString(string: value, mask: relaxedMask)
        }
        
        return value
    }
    
    public func hasValue(forField paymentProductFieldId: String) -> Bool {
        return attributes.hasValue(forField: paymentProductFieldId)
    }
    
    public func isReadOnly(field paymentProductFieldId: String) -> Bool {
        return attributes.isReadOnly(field: paymentProductFieldId)
    }
    
    public var label: String {
        var labelComponents = [String]()
        
        for labelTemplateItem in displayHints.labelTemplate.labelTemplateItems {
            let value = maskedValue(forField: labelTemplateItem.attributeKey)
            if !value.isEmpty {
                let trimmedValue = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                labelComponents.append(trimmedValue)
            }
        }
        
        return labelComponents.joined(separator: " ")
    }
    
}
