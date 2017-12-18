//
//  CustomerDetails.swift
//  Pods
//
//  Created for Ingenico ePayments on 12/07/2017.
//
//

import Foundation
public class CustomerDetails: ResponseObjectSerializable {
    public func value(key: String) -> String {
        return self.dict[key]!
    }
    public var values: [String:String] {
        return self.dict
    }
    private var dict: [String:String] = [:]
    public required init?(json: [String: Any]) {
        if let dict = json as? [String:String] {
            self.dict = dict
        }
    }

}
