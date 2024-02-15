//
//  AccountOnFileAttributesTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest

@testable import IngenicoConnectKit

class AccountOnFileAttributesTestCase: XCTestCase {

    let attributes = AccountOnFileAttributes()

    override func setUp() {
        super.setUp()

        let attribute1JSON = Data("""
        {
            "key": "key1",
            "value": "value1",
            "status": "READ_ONLY"
        }
        """.utf8)

        let attribute2JSON = Data("""
        {
            "key": "key2",
            "value": "value2",
            "status": "CAN_WRITE"
        }
        """.utf8)

        guard let attribute1 = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attribute1JSON),
              let attribute2 = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: attribute2JSON) else {
            XCTFail("Not all attributes are a valid AccountOnFileAttribute object")
            return
        }

        attributes.attributes.append(attribute1)
        attributes.attributes.append(attribute2)
    }

    func testValueForField() {
        XCTAssertEqual(attributes.value(forField: "key1"), "value1", "Incorrect value for key")
    }

    func testHasValueForFieldYes() {
        XCTAssert(attributes.hasValue(forField: "key1"), "Attributes should have a value for this key")
    }

    func testHasValueForFieldNo() {
        XCTAssert(!attributes.hasValue(forField: "key3"), "Attributes should not have a value for this key")
    }

    func testAttributes() {
        let readOnlyAttrJSON = Data("""
        {
            "key": "key3",
            "value": "value3",
            "status": "READ_ONLY"
        }
        """.utf8)
        guard let readOnlyAttr = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: readOnlyAttrJSON) else {
            XCTFail("Not a valid AccountOnFileAttribute")
            return
        }
        attributes.attributes.append(readOnlyAttr)
        XCTAssertTrue(attributes.isReadOnly(field: readOnlyAttr.key), "readOnlyAttr is not read only.")

        let readableAttrJSON = Data("""
        {
            "key": "readable",
            "value": "value3",
            "status": "CAN_WRITE"
        }
        """.utf8)
        guard let readableAttr = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: readableAttrJSON) else {
            XCTFail("Not a valid AccountOnFileAttribute")
            return
        }
        attributes.attributes.append(readableAttr)
        XCTAssertTrue(!attributes.isReadOnly(field: readableAttr.key), "readableAttr is read only.")

        let mustWriteAttrJSON = Data("""
        {
            "key": "readable",
            "value": "value3",
            "status": "MUST_WRITE"
        }
        """.utf8)
        guard let mustWriteAttr = try? JSONDecoder().decode(AccountOnFileAttribute.self, from: mustWriteAttrJSON) else {
            XCTFail("Not a valid AccountOnFileAttribute")
            return
        }
        attributes.attributes.append(mustWriteAttr)
        XCTAssertTrue(!attributes.isReadOnly(field: mustWriteAttr.key), "mustWriteAttr is read only.")
    }

}
