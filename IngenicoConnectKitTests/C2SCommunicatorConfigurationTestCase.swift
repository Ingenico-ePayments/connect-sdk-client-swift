//
//  C2SCommunicatorConfigurationTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class C2SCommunicatorConfigurationTestCase: XCTestCase {
  var configuration: C2SCommunicatorConfiguration!
  let util = StubUtil()

  override func setUp() {
    super.setUp()

    configuration =
      C2SCommunicatorConfiguration(
        clientSessionId: "",
        customerId: "",
        baseURL: "https://ams1.sandbox.api-ingenico.com/client/v1",
        assetBaseURL: "https://ams1.sandbox.api-ingenico.com/client/v1/assets",
        appIdentifier: "",
        util: util,
        loggingEnabled: false
      )
  }

  func testBaseURL() {
    XCTAssertEqual(configuration.baseURL, "https://ams1.sandbox.api-ingenico.com/client/v1", "Unexpected base URL")
  }

  func testAssetsBaseURL() {
    XCTAssertEqual(
        configuration.assetsBaseURL,
        "https://ams1.sandbox.api-ingenico.com/client/v1/assets",
        "Unexpected assets base URL"
    )
  }

  func testBase64EncodedClientMetaInfo() {
    XCTAssertEqual(
        configuration.base64EncodedClientMetaInfo,
        "base64encodedclientmetainfo",
        "Unexpected encoded client meta info"
    )
  }
}
