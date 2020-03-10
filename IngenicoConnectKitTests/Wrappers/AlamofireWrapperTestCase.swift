//
//  AlamofireWrapperTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import UIKit
import XCTest
import OHHTTPStubs

@testable import IngenicoConnectKit

class AlamofireWrapperTestCase: XCTestCase {
  let region = Region.EU
  let environment = Environment.sandbox
  var baseURL : String? = nil

  let host = "ams1.sandbox.api-ingenico.com"
  let merchantId = 1234

  override func setUp() {
    super.setUp()

    baseURL = Util.shared.C2SBaseURL(by: region, environment: environment)

    // Stub GET request
    stub(condition: isHost("\(host)") && isPath("/client/v1/\(merchantId)/crypto/publickey") && isMethodGET()) { _ in
      let response = [
        "errors": [[
          "code": 9002,
          "message": "MISSING_OR_INVALID_AUTHORIZATION"
        ]]
      ]
      return OHHTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type":"application/json"])
    }

    // Stub POST request
    stub(condition: isHost("\(host)") && isPath("/client/v1/\(merchantId)/sessions") && isMethodPOST()) { _ in
      let response = [
        "errors": [[
          "code": 9002,
          "message": "MISSING_OR_INVALID_AUTHORIZATION"
          ]]
        ]
      return OHHTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type":"application/json"])
    }

    stub(condition: isHost("\(host)") && isPath("/client/v1/noerror") && isMethodGET()) { _ in
      return OHHTTPStubsResponse(jsonObject: [], statusCode: 401, headers: ["Content-Type":"application/json"])
    }

    stub(condition: isHost("\(host)") && isPath("/client/v1/error") && isMethodGET()) { _ in
      return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: ["Content-Type":"application/json"])
    }
  }

  func testPost() {
    let sessionsURL = "\(baseURL!)/\(merchantId)/sessions"
    let expectation = self.expectation(description: "Response provided")

    AlamofireWrapper.shared.postResponse(forURL: sessionsURL, headers: nil, withParameters: nil, additionalAcceptableStatusCodes: nil, success: { responseObject in
      self.assertErrorResponse(responseObject, expectation: expectation)
    }, failure: { error in
      XCTFail("Unexpected failure while testing POST request: \(error.localizedDescription)")
    })

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        print("Timeout error: \(error.localizedDescription)")
      }
    }
  }

  func testGet() {
    let publicKeyURL = "\(baseURL!)/\(merchantId)/crypto/publickey"
    let expectation = self.expectation(description: "Response provided")

    AlamofireWrapper.shared.getResponse(forURL: publicKeyURL, headers: nil, additionalAcceptableStatusCodes: nil, success: { responseObject in
      self.assertErrorResponse(responseObject, expectation: expectation)
    }, failure: { error in
      XCTFail("Unexpected failure while testing GET request: \(error.localizedDescription)")
    })

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        print("Timeout error: \(error.localizedDescription)")
      }
    }
  }

  func testAdditionalStatusCodeAcceptance() {
    let publicKeyURL = "\(baseURL!)/noerror"
    let expectation = self.expectation(description: "Response provided")
    let additionalAcceptableStatusCodes : IndexSet = [401]

    AlamofireWrapper.shared.getResponse(forURL: publicKeyURL, headers: nil, additionalAcceptableStatusCodes: additionalAcceptableStatusCodes, success: { responseObject in
      expectation.fulfill()
    }, failure: { error in
      XCTFail("Additional status code did not accept: \(error.localizedDescription)")
    })

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        print("Timeout error: \(error.localizedDescription)")
      }
    }
  }

  func testRequestFailure() {
    let customerId = "1234"
    let publicKeyURL = "\(baseURL!)/\(customerId)/error"
    let expectation = self.expectation(description: "Response provided")

    AlamofireWrapper.shared.getResponse(forURL: publicKeyURL, headers: nil, additionalAcceptableStatusCodes: nil, success: { responseObject in
      XCTFail("Failure should have been called")
    }, failure: { error in
      expectation.fulfill()
    })

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        print("Timeout error: \(error.localizedDescription)")
      }
    }
  }

  fileprivate func assertErrorResponse(_ errorResponse: [String: Any]?, expectation: XCTestExpectation) {
    if let errorResponse = errorResponse,
    let errors = errorResponse["errors"] as? [[String:Any]],
       let firstError = errors.first
    {
      XCTAssertEqual(firstError["code"] as? Int, 9002)
      XCTAssertEqual(firstError["message"] as? String, "MISSING_OR_INVALID_AUTHORIZATION")
      expectation.fulfill()
    }
  }
}
