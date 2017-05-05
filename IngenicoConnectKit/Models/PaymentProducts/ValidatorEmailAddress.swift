//
//  ValidatorEmailAddress.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class ValidatorEmailAddress: Validator {
    public var expression: NSRegularExpression
    
    public override init() {
        let qtext = "[^\\x0d\\x22\\x5c\\x80-\\xff]"
        let dtext = "[^\\x0d\\x5b-\\x5d\\x80-\\xff]"
        let atom = "[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+"
        let quoted_pair = "\\x5c[\\x00-\\x7f]"
        let domain_literal = "\\x5b(\(dtext)|\(quoted_pair))*\\x5d"
        let quoted_string = "\\x22(\(qtext)|\(quoted_pair))*\\x22"
        let domain_ref = atom
        let sub_domain = "(\(domain_ref)|\(domain_literal))"
        let word = "(\(atom)|\(quoted_string))"
        let domain = "\(sub_domain)(\\x2e\(sub_domain))*"
        let local_part = "\(word)(\\x2e\(word))*"
        let addr_spec = "\(local_part)\\x40\(domain)"
        let complete = "^\(addr_spec)$"
        
        expression = try! NSRegularExpression(pattern: complete)
    }
    
    public override func validate(value: String, for request: PaymentRequest) {
        super.validate(value: value, for: request)
        
        let numberOfMatches = expression.numberOfMatches(in: value , range: NSMakeRange(0, value.length))
        if numberOfMatches != 1 {
            let error = ValidationErrorEmailAddress()
            errors.append(error)
        }
    }
}
