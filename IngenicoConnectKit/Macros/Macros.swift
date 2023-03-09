//
//  Macros.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class Macros {
    public static func DLog(message: String, functionName: String = #function, fileName: String = #file) {
        #if DEBUG
            print(
                """
                DLog: Original_Message = \(message)\n Method_Name = \(functionName)\n
                File_Name = \(fileName)\n Line_Number = \(#line)
                """
            )
        #else
            print("DLog: Original_Message = \(message)")
        #endif
    }
}
