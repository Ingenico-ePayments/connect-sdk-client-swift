//
//  LabelTemplateTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class LabelTemplateTestCase: XCTestCase {

    let template = LabelTemplate()

    override func setUp() {
        super.setUp()

        let item1 = LabelTemplateItem(json: ["attributeKey": "key1", "mask": "mask1"])
        let item2 = LabelTemplateItem(json: ["attributeKey": "key2", "mask": "mask2"])

        template.labelTemplateItems.append(item1!)
        template.labelTemplateItems.append(item2!)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testMaskForAttributeKey() {
        let mask = template.mask(forAttributeKey: "key1")

        XCTAssertNotNil(mask, "Mask could not be found")
        XCTAssertEqual(mask, "mask1", "Unexpected mask encountered")
    }

}
