//
//  PreparedPaymentRequest.swift
//  IngenicoConnectKit
//
//  Created by Fabian Giger on 06-04-17.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class PreparedPaymentRequestTestCase: XCTestCase {

    func testPreparedPaymentRequest() {
        let encrypted = "encrypted"
        let meta = "Meta info"
        let request = PreparedPaymentRequest(encryptedFields: encrypted, encodedClientMetaInfo: meta)
        XCTAssertTrue(request.encodedClientMetaInfo == meta, "Meta info was incorrect.")
        XCTAssertTrue(request.encryptedFields == encrypted, "Encrypted was incorrect.")

        request.encryptedFields = "encrypted1"
        XCTAssertTrue(request.encryptedFields == "encrypted1", "Encrypted was incorrect.")
    }

}
