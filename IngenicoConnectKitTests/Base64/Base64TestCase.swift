//
//  Base64TestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class Base64TestCase: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testEncodeRevertable() {
    let input = Data(bytes: [0, 255, 43, 1])
    let string = input.encode()
    let output = string.decode()
    XCTAssertEqual(output, input, "encoded and decoded data differs from the untransformed data")
  }

  func testURLEncodeRevertable() {
    let input = Data(bytes: [0, 255, 43, 1])
    let string = input.base64URLEncode()
    let output = string.base64URLDecode()
    XCTAssertEqual(output, input, "URL encoded and URL decoded data differs from the untransformed data")
  }

  func testEncode() {
    if let data = "1234".data(using: String.Encoding.utf8) {
      let output = data.encode()
      XCTAssertEqual(output, "MTIzNA==", "Encoded data does not match expected output")
    }
  }

  func testURLEncode() {
    if let data = "1234".data(using: String.Encoding.utf8) {
      let output = data.base64URLEncode()
      XCTAssertEqual(output, "MTIzNA", "Encoded data does not match expected output")
    }
  }
}
