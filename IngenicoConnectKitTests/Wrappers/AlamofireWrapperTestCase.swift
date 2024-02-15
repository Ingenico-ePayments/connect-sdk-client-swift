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
    let baseURL = "https://ams1.sandbox.api-ingenico.com/client/v1"

    let host = "ams1.sandbox.api-ingenico.com"
    let merchantId = 1234

    override func setUp() {
        super.setUp()

        // Stub GET request
        stub(
            condition: isHost("\(host)") &&
            isPath("/client/v1/\(merchantId)/crypto/publickey") &&
            isMethodGET()
        ) { _ in
            let response = [
                "errorId": "id",
                "errors": [[
                    "category": "Test failure",
                    "code": "9002",
                    "httpStatusCode": 200,
                    "id": "1",
                    "message": "MISSING_OR_INVALID_AUTHORIZATION"
                ]]
            ]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        // Stub POST request
        stub(condition: isHost("\(host)") && isPath("/client/v1/\(merchantId)/sessions") && isMethodPOST()) { _ in
            let response = [
                "errorId": "id",
                "errors": [[
                    "category": "Test failure",
                    "code": "9002",
                    "httpStatusCode": 200,
                    "id": "1",
                    "message": "MISSING_OR_INVALID_AUTHORIZATION"
                ]]
            ]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isHost("\(host)") && isPath("/client/v1/noerror") && isMethodGET()) { _ in
            let response = [
                "convertedAmount": 123
            ]
            return
                HTTPStubsResponse(jsonObject: response, statusCode: 401, headers: ["Content-Type": "application/json"])
        }

        stub(condition: isHost("\(host)") && isPath("/client/v1/error") && isMethodGET()) { _ in
            return HTTPStubsResponse(jsonObject: [], statusCode: 500, headers: ["Content-Type": "application/json"])
        }
    }

    func testPost() {
        let sessionsURL = "\(baseURL)/\(merchantId)/sessions"
        let expectation = self.expectation(description: "Response provided")

        let successHandler: (ApiErrorResponse?, Int?) -> Void = { (responseObject, _) -> Void in
            self.assertApiError(responseObject, expectation: expectation)
        }

        AlamofireWrapper.shared.postResponse(
            forURL: sessionsURL,
            headers: nil,
            withParameters: nil,
            additionalAcceptableStatusCodes: nil,
            success: successHandler,
            failure: { error in
                XCTFail("Unexpected failure while testing POST request: \(error.localizedDescription)")
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected failure while testing POST request: \(errorResponse.errors[0].message)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testGet() {
        let publicKeyURL = "\(baseURL)/\(merchantId)/crypto/publickey"
        let expectation = self.expectation(description: "Response provided")

        let successHandler: (ApiErrorResponse?, Int?) -> Void = { (responseObject, _) -> Void in
            self.assertApiError(responseObject, expectation: expectation)
        }

        AlamofireWrapper.shared.getResponse(
            forURL: publicKeyURL,
            headers: nil,
            additionalAcceptableStatusCodes: nil,
            success: successHandler,
            failure: { error in
                XCTFail("Unexpected failure while testing GET request: \(error.localizedDescription)")
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected failure while testing POST request: \(errorResponse.errors[0].message)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testAdditionalStatusCodeAcceptance() {
        let publicKeyURL = "\(baseURL)/noerror"
        let expectation = self.expectation(description: "Response provided")
        let additionalAcceptableStatusCodes: IndexSet = [401]

        let successHandler: (ConvertedAmountResponse?, Int?) -> Void = { (_, _) -> Void in
            expectation.fulfill()
        }

        AlamofireWrapper.shared.getResponse(
            forURL: publicKeyURL,
            headers: nil,
            additionalAcceptableStatusCodes: additionalAcceptableStatusCodes,
            success: successHandler,
            failure: { error in
                XCTFail("Additional status code did not accept: \(error.localizedDescription)")
            },
            apiFailure: { errorResponse in
                XCTFail("Additional status code did not accept: \(errorResponse.errors[0].message)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testRequestFailure() {
        let customerId = "1234"
        let publicKeyURL = "\(baseURL)/\(customerId)/error"
        let expectation = self.expectation(description: "Response provided")

        let successHandler: (ApiErrorResponse?, Int?) -> Void = { (_, _) -> Void in
            XCTFail("Failure should have been called")
        }

        AlamofireWrapper.shared.getResponse(
            forURL: publicKeyURL,
            headers: nil,
            additionalAcceptableStatusCodes: nil,
            success: successHandler,
            failure: { _ in
                expectation.fulfill()
            },
            apiFailure: { _ in
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    fileprivate func assertApiError(_ apiError: ApiErrorResponse?, expectation: XCTestExpectation) {
        if let apiError {
            let apiErrorItem = apiError.errors[0]
            XCTAssertEqual(apiErrorItem.code, "9002")
            XCTAssertEqual(apiErrorItem.message, "MISSING_OR_INVALID_AUTHORIZATION")
            expectation.fulfill()
        }
    }
}
