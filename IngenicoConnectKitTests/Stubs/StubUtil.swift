//
//  StubUtil.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

@testable import IngenicoConnectKit

class StubUtil: Util {
  override func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?) -> String? {
    return "base64encodedclientmetainfo"
  }
}
