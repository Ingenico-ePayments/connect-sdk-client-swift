//
//  AccountsOnFile.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class AccountsOnFile {
    
    public var accountsOnFile = [AccountOnFile]()
    
    public func accountOnFile(withIdentifier identifier: String) -> AccountOnFile? {
        for accountOnFile in accountsOnFile
            where accountOnFile.identifier.isEqual(identifier){
                return accountOnFile
        }
        return nil
    }
}
