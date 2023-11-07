//
//  UtilTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class UtilTestCase: XCTestCase {
  let util = Util.shared

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testBase64EncodedClientMetaInfo() {
      if let info = util.base64EncodedClientMetaInfo {
          let decodedInfo = info.decode()

          guard let JSON = try? JSONSerialization.jsonObject(with: decodedInfo, options: []) as? [String: String] else {
              XCTFail("Could not deserialize JSON")
              return
          }

          XCTAssertEqual(JSON["deviceBrand"], "Apple", "Incorrect device brand in meta info")
          XCTAssertEqual(JSON["deviceType"], "x86_64", "Incorrect device type in meta info")
      }
  }

  func testBase64EncodedClientMetaInfoWithAddedData() {
      if let info = util.base64EncodedClientMetaInfo(withAddedData: ["test": "value"]) {
        let decodedInfo = info.decode()

        guard let JSON = try? JSONSerialization.jsonObject(with: decodedInfo, options: []) as? [String: String] else {
            XCTFail("Could not deserialize JSON")
            return
        }

        XCTAssertEqual(JSON["test"], "value", "Incorrect value for added key in meta info")
    }
  }
}
