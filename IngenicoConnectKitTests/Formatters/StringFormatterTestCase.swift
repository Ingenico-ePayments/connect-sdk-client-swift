//
//  StringFormatterTestCase.swift
//  IngenicoConnectKitTests
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class StringFormatterTestCase: XCTestCase {

  let stringFormatter = StringFormatter()

  func testFormatStringNumbers() {
    let input = "1234567890"
    let mask = "{{99}} {{99}} {{99}} {{99}} {{99}}"
    let output = stringFormatter.formatString(string: input, mask: mask)
    let expectedOutput = "12 34 56 78 90"
    XCTAssertEqual(output, expectedOutput, "Masking with numeric characters has failed")
  }

  func testFormatStringWildcards() {
    let input = "!!!!!!!!!!"
    let mask = "{{**}} {{**}} {{**}} {{**}} {{**}}"
    let output = stringFormatter.formatString(string: input, mask: mask)
    let expectedOutput = "!! !! !! !! !!"

    XCTAssertEqual(output, expectedOutput, "Masking with wildcards has failed")
  }

  func testFormatStringAlpha() {
    let input = "abcdefghij"
    let mask = "{{aa}} {{aa}} {{aa}} {{aa}} {{aa}}"
    let output = stringFormatter.formatString(string: input, mask: mask)
    let expectedOutput = "ab cd ef gh ij"

    XCTAssertEqual(output, expectedOutput, "Masking with alphabetic characters has failed")
  }

  func testFormStringWithCursorPosition() {
    let input = "abcdefghij"
    var cursorPosition = 10
    let mask = "{{aa}} {{aa}} {{aa}} {{aa}} {{aa}}"
    let output = stringFormatter.formatString(string: input, mask: mask, cursorPosition: &cursorPosition)
    let expectedOutput = "ab cd ef gh ij"

    XCTAssertEqual(output, expectedOutput, "Masking with cursor position has failed")
  }

  func testUnformatString() {
    let input = "12 34 56 78 90"
    let mask = "{{99}} {{99}} {{99}} {{99}} {{99}}"
    let output = stringFormatter.unformatString(string: input, mask: mask)
    let expectedOutput = "1234567890"
    XCTAssertEqual(output, expectedOutput, "Unmasking a string has failed")
  }

  func testRelaxMask() {
    let input = "{{9999}}/{{aaaa}}+{{****}}"
    let output = stringFormatter.relaxMask(mask: input)
    let expectedOutput = "{{****}}/{{****}}+{{****}}"

    XCTAssertEqual(output, expectedOutput, "Relaxing a mask has failed")
  }

}
