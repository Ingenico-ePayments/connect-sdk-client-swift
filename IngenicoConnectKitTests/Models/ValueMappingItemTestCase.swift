//
//  ValueMappingItemTestCase.swift
//  IngenicoConnectKit
//
//  Created by Fabian Giger on 11-04-17.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

import XCTest

@testable import IngenicoConnectKit

class ValueMappingItemTestCase: XCTestCase {

    func testExample() {
        let itemJSON = Data("""
        {
            "displayName": "displayName",
            "value": "value",
        }
        """.utf8)

        guard let item = try? JSONDecoder().decode(ValueMappingItem.self, from: itemJSON) else {
            XCTFail("Not a valid ValueMappingItem")
            return
        }

        XCTAssertTrue(item.displayName == "displayName", "Unexpected")
        XCTAssertTrue(item.value == "value", "Unexpected")
    }
}
