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

        let item1JSON = Data("""
        {
            "attributeKey": "key1",
            "mask": "mask1"
        }
        """.utf8)
        guard let item1 = try? JSONDecoder().decode(LabelTemplateItem.self, from: item1JSON) else {
            XCTFail("Not a valid LabelTemplateItem")
            return
        }

        let item2JSON = Data("""
        {
            "attributeKey": "key2",
            "mask": "mask2"
        }
        """.utf8)
        guard let item2 = try? JSONDecoder().decode(LabelTemplateItem.self, from: item2JSON) else {
            XCTFail("Not a valid LabelTemplateItem")
            return
        }

        template.labelTemplateItems.append(item1)
        template.labelTemplateItems.append(item2)
    }

    func testMaskForAttributeKey() {
        let mask = template.mask(forAttributeKey: "key1")

        XCTAssertNotNil(mask, "Mask could not be found")
        XCTAssertEqual(mask, "mask1", "Unexpected mask encountered")
    }

}
