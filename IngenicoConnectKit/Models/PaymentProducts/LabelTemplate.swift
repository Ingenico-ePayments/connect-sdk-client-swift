//
//  LabelTemplate.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class LabelTemplate {
    
    public var labelTemplateItems = [LabelTemplateItem]()
    
    public func mask(forAttributeKey key: String) -> String? {
        for labelTemplateItem in labelTemplateItems where labelTemplateItem.attributeKey.isEqual(key){
            return labelTemplateItem.mask
        }
        return nil
    }
    
}
