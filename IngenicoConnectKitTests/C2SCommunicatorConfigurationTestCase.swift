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

    configuration = C2SCommunicatorConfiguration(clientSessionId: "", customerId: "", region: .EU, environment: .sandbox, util: util)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testBaseURL() {
    XCTAssertEqual(configuration.baseURL, "c2sbaseurlbyregion", "Unexpected base URL")
  }

  func testAssetsBaseURL() {
    XCTAssertEqual(configuration.assetsBaseURL, "assetsbaseurlbyregion", "Unexpected assets base URL")
  }

  func testBase64EncodedClientMetaInfo() {
    print(configuration.base64EncodedClientMetaInfo ?? "leeg")
    XCTAssertEqual(configuration.base64EncodedClientMetaInfo, "base64encodedclientmetainfo", "Unexpected encoded client meta info")
  }
}
