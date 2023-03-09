//
//  StubBundle.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

class StubBundle: Bundle {
  override func path(forResource name: String?, ofType ext: String?) -> String? {
    switch name! {
    case "imageMapping":
        return "imageMappingFile"

    default:
        return nil
    }
  }
}
