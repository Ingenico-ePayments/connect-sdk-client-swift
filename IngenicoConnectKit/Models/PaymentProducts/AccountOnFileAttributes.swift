//
//  AccountOnFileAttributes.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class AccountOnFileAttributes {
    
    public var attributes = [AccountOnFileAttribute]()
    
    public func value(forField paymentProductFieldId: String) -> String {
        for attribute in attributes {
            if attribute.key == paymentProductFieldId, let val = attribute.value {
                return val
            }
        }
        
        return ""
    }
    
    public func hasValue(forField paymentProductFieldId: String) -> Bool {
        for attribute in attributes
            where attribute.key == paymentProductFieldId {
                return true
        }
        
        return false
    }
    
    public func isReadOnly(field paymentProductFieldId: String?) -> Bool {
        guard let field = paymentProductFieldId else {
            return false
        }
        for attribute in attributes
            where attribute.key.isEqual(field) {
                return attribute.status == .readOnly
        }
        return false
    }
    
}
