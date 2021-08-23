//
//  PaymentRequest.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class PaymentRequest {
    
    public var paymentProduct: PaymentProduct?
    public var errors: [ValidationError] = []
    public var tokenize = false
    
    public var fieldValues = [String:String]()
    public var formatter = StringFormatter()

    public var accountOnFile: AccountOnFile?

    public init(paymentProduct: PaymentProduct, accountOnFile: AccountOnFile? = nil, tokenize: Bool? = false) {
        self.paymentProduct = paymentProduct
        self.accountOnFile = accountOnFile
        self.tokenize = tokenize ?? false
    }
    
    public func setValue(forField paymentProductFieldId: String, value: String) {
        fieldValues[paymentProductFieldId] = value
    }
    
    public func getValue(forField paymentProductFieldId: String) -> String? {
        if let value = fieldValues[paymentProductFieldId] {
            return value
        }

        var value: String? = nil
        if let paymentProduct = paymentProduct, let field = paymentProduct.paymentProductField(withId: paymentProductFieldId),
            let fixedListValidator = field.dataRestrictions.validators.validators.filter({ $0 is ValidatorFixedList }).first as? ValidatorFixedList,
            let allowedValue = fixedListValidator.allowedValues.first
        {
            value = allowedValue
            setValue(forField: paymentProductFieldId, value: allowedValue)
        }
        
        return value
    }
    
    public func maskedValue(forField paymentProductFieldId: String) -> String? {
        var cursorPosition = 0

        return maskedValue(forField: paymentProductFieldId, cursorPosition: &cursorPosition)
    }
    
    public func maskedValue(forField paymentProductFieldId: String, cursorPosition: inout Int) -> String? {
        guard let value = getValue(forField: paymentProductFieldId) else {
            return nil
        }
        if let mask = mask(forField: paymentProductFieldId) {
            return formatter.formatString(string: value, mask: mask, cursorPosition: &cursorPosition)
        }
        
        return value
    }
    
    public func unmaskedValue(forField paymentProductFieldId: String) -> String? {
        guard  let value = getValue(forField: paymentProductFieldId) else {
            return nil
        }
        if let mask = mask(forField: paymentProductFieldId) {
            return formatter.unformatString(string: value, mask: mask)
        }
        
        return value
    }
    
    public func isPartOfAccountOnFile(field paymentProductFieldId: String) -> Bool {
        return accountOnFile?.hasValue(forField: paymentProductFieldId) ?? false
    }
    
    public func isReadOnly(field paymentProductFieldId: String) -> Bool {
        if !isPartOfAccountOnFile(field: paymentProductFieldId) {
            return false
        } else if let accountOnFile = accountOnFile {
            return accountOnFile.isReadOnly(field: paymentProductFieldId)
        }
        return false
    }
    
    public func mask(forField paymentProductFieldId: String) -> String? {
        guard let paymentProduct = paymentProduct else {
            return nil
        }
        let field = paymentProduct.paymentProductField(withId: paymentProductFieldId)
        let mask = field?.displayHints.mask
        
        return mask
    }
    
    public func validate() {
        guard let paymentProduct = paymentProduct else {
            NSException(name: NSExceptionName(rawValue: "Invalid payment product"), reason: "Payment product is invalid").raise()
            return
        }
        
        errors.removeAll()
        
        for field in paymentProduct.fields.paymentProductFields {
            if let fieldValue = unmaskedValue(forField: field.identifier),
               !isPartOfAccountOnFile(field: field.identifier) {
                field.validateValue(value: fieldValue, for: self)
                errors.append(contentsOf: field.errors)
            }
        }
    }
    
    public var unmaskedFieldValues: [String: String]? {
        guard let paymentProduct = paymentProduct else {
            NSException(name: NSExceptionName(rawValue: "Invalid payment product"), reason: "Payment product is invalid").raise()
            return nil
        }
        
        var unmaskedFieldValues = [String: String]()
        
        for field in paymentProduct.fields.paymentProductFields where !isReadOnly(field: field.identifier) {
            let unmasked = unmaskedValue(forField: field.identifier)
            unmaskedFieldValues[field.identifier] = unmasked
        }
        
        return unmaskedFieldValues
    }
}













