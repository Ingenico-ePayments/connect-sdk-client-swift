//
//  StubUtil.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

@testable import IngenicoConnectKit

class StubUtil: Util {

  override func C2SBaseURL(by region: Region, environment: Environment) -> String {
    return "c2sbaseurlbyregion"
  }

  override func assetsBaseURL(by region: Region, environment: Environment) -> String {
    return "assetsbaseurlbyregion"
  }

  override func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?) -> String? {
    return "base64encodedclientmetainfo"
  }
}
