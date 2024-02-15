//
//  PaymentItemsTestCase.swift
//  IngenicoConnectKit
//
//  Created by Fabian Giger on 03-04-17.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

import XCTest

@testable import IngenicoConnectKit

class BasicPaymentProductGroupsTestCase: XCTestCase {
    let basicPaymentProductGroups = BasicPaymentProductGroups()

    override func setUp() {
        super.setUp()

        for index in 1..<6 {
            let basicPaymentProductGroupDictionary = [
                "id": "\(index)",
                "displayHints": [
                    "displayOrder": 20,
                    "label": "Visa",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                ],
                "deviceFingerprintEnabled": true,
                "allowsInstallments": false,
                "accountsOnFile": [[
                    "id": index,
                    "paymentProductId": index
                ]]
            ] as [String: Any]

            guard let basicPaymentProductGroupJSON =
                    try? JSONSerialization.data(withJSONObject: basicPaymentProductGroupDictionary) else {
                XCTFail("Not a valid Dictionary")
                return
            }
            guard let basicPaymentProductGroup =
                    try? JSONDecoder().decode(BasicPaymentProductGroup.self, from: basicPaymentProductGroupJSON) else {
                XCTFail("Not a valid BasicPaymentProductGroup")
                return
            }

            basicPaymentProductGroups.paymentProductGroups.append(basicPaymentProductGroup)
        }
        basicPaymentProductGroups.sort()
    }

    func testBasicPaymentProductGroupValues() {
        guard let basicPaymentProductGroup = basicPaymentProductGroups.paymentProductGroups.first else {
            XCTFail("basicPaymentProductGroups array was empty.")
            return
        }

        XCTAssertEqual(basicPaymentProductGroup.identifier, "1")
        XCTAssertEqual(basicPaymentProductGroup.displayHints.displayOrder, 20)
        XCTAssertEqual(basicPaymentProductGroup.displayHints.label, "Visa")
        XCTAssertEqual(
            basicPaymentProductGroup.displayHints.logoPath,
            "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
        )
        XCTAssertTrue(basicPaymentProductGroup.deviceFingerprintEnabled)
        XCTAssertFalse(basicPaymentProductGroup.allowsInstallments)
        XCTAssertEqual(basicPaymentProductGroup.accountsOnFile.accountsOnFile[0].identifier, "1")
        XCTAssertEqual(basicPaymentProductGroup.accountsOnFile.accountsOnFile[0].paymentProductIdentifier, "1")
    }

    func testBasicPaymentProductGroupHasAccountOnFile() {
        XCTAssertTrue(basicPaymentProductGroups.hasAccountsOnFile, "BasicPaymentProductGroups has no accounts on file.")

        guard let paymentGroup = basicPaymentProductGroups.paymentProductGroups.first else {
            XCTFail("PaymentProductGroups array was empty.")
            return
        }

        let testAccountOnFileJSON = Data("""
        {
            "id": 1,
            "paymentProductId": 1
        }
        """.utf8)
        guard let testAccountOnFile = try? JSONDecoder().decode(AccountOnFile.self, from: testAccountOnFileJSON) else {
            XCTFail("Not a valid AccountOnFile")
            return
        }
        let foundAccountOnFile = paymentGroup.accountOnFile(withIdentifier: testAccountOnFile.identifier)
        XCTAssertTrue(foundAccountOnFile != nil, "Account on file identifier didn't match.")

        testAccountOnFile.identifier = "2"
        let didntFindAccountOnFile = paymentGroup.accountOnFile(withIdentifier: testAccountOnFile.identifier)
        XCTAssertTrue(didntFindAccountOnFile == nil, "Account on file identifier didn't match.")
    }

    func testFindProductGroupById() {
        let id = "2"
        let prodGroup = basicPaymentProductGroups.paymentProductGroup(withIdentifier: id)
        XCTAssertTrue(prodGroup != nil, "Product group with ID: \(id) was not found.")
    }

    func testPaymentGroup() {
        let foundGroup = basicPaymentProductGroups.paymentProductGroup(withIdentifier: "1")
        XCTAssertTrue(foundGroup != nil, "Group was not found.")

        let nonExistingGroup = basicPaymentProductGroups.paymentProductGroup(withIdentifier: "999")
        XCTAssertTrue(
            nonExistingGroup == nil,
            "Group was not suppose to be found: \(String(describing: nonExistingGroup))."
        )
    }

    func testLogoPath() {
        guard let group = basicPaymentProductGroups.paymentProductGroup(withIdentifier: "1") else {
            XCTFail("Did not find group.")
            return
        }
        let displayHintsJSON = Data("""
        {
            "logo": "logoPath",
            "displayOrder": 0
        }
        """.utf8)

        guard let displayHints =
                try? JSONDecoder().decode(PaymentItemDisplayHints.self, from: displayHintsJSON) else {
            XCTFail("Not a valid PaymentItemDisplayHints")
            return
        }
        group.displayHints = displayHints

        XCTAssertTrue(basicPaymentProductGroups.logoPath(forProductGroup: "1") != nil, "Logo path was nil.")
        XCTAssertTrue(basicPaymentProductGroups.logoPath(forProductGroup: "999") == nil, "Logo path was not nil.")
    }
}
