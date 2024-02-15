//
//  CustomerDetailsTestCase.swift
//  IngenicoConnectKitTests
//
//  Created for Ingenico ePayments on 24/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class CustomerDetailsTestCase: XCTestCase {

    func testDecodingCustomerDetails() {
        let customerDetailsJSON = Data("""
        {
            "fiscalNumber" : "01234567890",
            "city" : "Stockholm",
            "street" : "Gustav Adolfs torg 22",
            "zip" : "111 52",
            "firstName" : "Gustav",
            "surname" : "Adolfs",
            "emailAddress" : "gustav.adolfs@stockholm.se",
            "phoneNumber" : "0123456789",
            "languageCode" : ""
        }
        """.utf8)

        guard let customerDetails = try? JSONDecoder().decode(CustomerDetails.self, from: customerDetailsJSON) else {
            XCTFail("Not a valid CustomerDetails")
            return
        }

        XCTAssertEqual(customerDetails.values["fiscalNumber"], "01234567890")
        XCTAssertEqual(customerDetails.values["city"], "Stockholm")
        XCTAssertEqual(customerDetails.values["street"], "Gustav Adolfs torg 22")
        XCTAssertEqual(customerDetails.values["zip"], "111 52")
        XCTAssertEqual(customerDetails.values["firstName"], "Gustav")
        XCTAssertEqual(customerDetails.values["surname"], "Adolfs")
        XCTAssertEqual(customerDetails.values["emailAddress"], "gustav.adolfs@stockholm.se")
        XCTAssertEqual(customerDetails.values["phoneNumber"], "0123456789")
        XCTAssertEqual(customerDetails.values["languageCode"], "")
    }
}
