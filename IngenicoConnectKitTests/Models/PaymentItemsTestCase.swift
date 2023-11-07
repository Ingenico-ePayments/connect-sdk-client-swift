//
//  PaymentItemsTestCase.swift
//  IngenicoConnectKit
//
//  Created by Fabian Giger on 04-04-17.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import IngenicoConnectKit

class PaymentItemsTestCase: XCTestCase {

    let host = "ams1.sandbox.api-ingenico.com"

    var session = Session(clientSessionId: "client-session-id",
                          customerId: "customer-id",
                          region: .EU,
                          environment: .sandbox,
                          appIdentifier: "")
    let context = PaymentContext(amountOfMoney: PaymentAmountOfMoney(totalAmount: 3, currencyCode: .EUR),
                                 isRecurring: true,
                                 countryCode: .NL)

    override func setUp() {
        super.setUp()
        session.assetManager.fileManager = StubFileManager()
        session.assetManager.sdkBundle = StubBundle()

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPaymentItems() {
        stub(condition: isHost("\(host)") && isPath("/client/v1/customer-id/products") && isMethodGET()) { _ in
        let response = [
                    "paymentProducts": [
                        [
                            "allowsRecurring": true,
                            "allowsTokenization": true,
                            "displayHints": [
                                "displayOrder": 20,
                                "label": "Visa",
                                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                            ],
                            "id": 1,
                            "maxAmount": 1000000,
                            "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                            "paymentMethod": "card",
                            "paymentProductGroup": "cards",
                            "acquirerCountry": "NL"
                        ],
                        [
                            "allowsRecurring": true,
                            "allowsTokenization": true,
                            "displayHints": [
                                "displayOrder": 19,
                                "label": "American Express",
                                "logo": "/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
                            ],
                            "id": 2,
                            "maxAmount": 1000000,
                            "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                            "paymentMethod": "card",
                            "paymentProductGroup": "cards"
                        ],
                        [
                            "allowsRecurring": true,
                            "allowsTokenization": true,
                            "displayHints": [
                                "displayOrder": 18,
                                "label": "MasterCard",
                                "logo": "/templates/master/global/css/img/ppimages/pp_logo_3_v1.png"
                            ],
                            "id": 3,
                            "maxAmount": 1000000,
                            "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                            "paymentMethod": "card",
                            "paymentProductGroup": "cards",
                            "accountsOnFile": [
                                [
                                    "id": 1,
                                    "paymentProductId": 3,
                                    "displayHints": [
                                        [
                                            "attributeKey": "17",
                                            "mask": "12345"
                                        ],
                                        [
                                            "attributeKey": "2",
                                            "mask": "{{99999}}"
                                        ]
                                    ],
                                    "attributes": [
                                        [
                                            "key": "1",
                                            "value": "2",
                                            "mustWriteReason": "Must",
                                            "status": "READ_ONLY"
                                        ]
                                    ]
                                ],
                                [
                                    "id": 2,
                                    "paymentProductId": 4
                                ]
                            ]
                        ]
                    ]
                ]
            return
                OHHTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        stub(condition: isHost("\(host)") && isPath("/client/v1/customer-id/productgroups") && isMethodGET()) { _ in
            let response = [
                    "paymentProductGroups": [
                        [
                            "displayHints": [
                                "displayOrder": 20,
                                "label": "Cards",
                                "logo": "/templates/master/global/css/img/ppimages/group-card.png"
                            ],
                            "id": "cards",
                            "acquirerCountry": "NL",
                            "accountsOnFile": [
                                [
                                    "id": 1,
                                    "paymentProductId": 3
                                ],
                                [
                                    "id": 2,
                                    "paymentProductId": 4
                                ]
                            ]
                        ]
                    ]
                ]
            return
                OHHTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")
        session.paymentItems(for: context, groupPaymentProducts: true, success: { (items) in

            items.sort()

            XCTAssertTrue(items.hasAccountsOnFile, "Accounts on file are missing.")

            self.paymentItems(paymentItems: items)
            self.allPaymentItems(basicItems: items.allPaymentItems)

            XCTAssertTrue(items.paymentItem(withIdentifier: "3") != nil, "Payment item was not found.")
            XCTAssertTrue(items.paymentItem(withIdentifier: "999") == nil, "Payment item should not have been found.")

            XCTAssertTrue(items.logoPath(forItem: "3") != nil, "Logo path not found.")
            XCTAssertTrue(
                items.logoPath(forItem: "0000") == nil,
                "Logo path should been nil: \(String(describing: items.logoPath(forItem: "0000")))."
            )

            let sortedItems = items.paymentItems.sorted {
                guard let displayOrder0 = $0.displayHints.displayOrder,
                      let displayOrder1 = $1.displayHints.displayOrder else {
                    return false
                }
                return displayOrder0 < displayOrder1
            }

            items.sort()
            for index in 0..<sortedItems.count
                where sortedItems[index].identifier != items.paymentItems[index].identifier {
                XCTFail(
                    """
                    Sorted order is not the same: \(items.paymentItems[index].identifier)
                    should have been: \(sortedItems[index].identifier)
                    """
                )
            }

            expectation.fulfill()
        }, failure: { (error) in
            XCTFail("Unexpected failure while loading Payment groups: \(error.localizedDescription)")
            expectation.fulfill()
        })
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }

        XCTAssertTrue(AccountOnFile(json: ["": ""]) == nil, "Init of the account on file should have failed.")
        XCTAssertTrue(
            AccountOnFile(json: ["id": "string id"]) == nil,
            "Init of the account on file should have failed."
        )

        XCTAssertTrue(AccountOnFile(
            json: ["id": 1, "paymentProductId": ""]) == nil,
                      "Init of the account on file should have failed. Based on the payment product ID."
        )
        XCTAssertTrue(
            AccountOnFile(json: ["id": 1, "paymentProductId": "string id"]) == nil,
            "Init of the account on file should have failed. Based on the payment product ID."
        )

    }

    func paymentItems(paymentItems: PaymentItems) {
        guard let items = paymentItems.paymentItems as? [BasicPaymentProductGroup] else {
            XCTFail("Basic items was not of type BasicPaymentProductGroup.")
            return
        }
        for item in items {
            XCTAssertTrue(item.identifier == "cards", "Group identifier was equel to Cards.")
            XCTAssertTrue(
                item.displayHints.displayOrder != nil,
                "Display order was nil (\(String(describing: item.displayHints.displayOrder)))."
            )
            XCTAssertTrue(
                item.displayHints.logoPath == "/templates/master/global/css/img/ppimages/group-card.png",
                "Logo path was incorrect."
            )
            XCTAssertTrue(item.displayHints.logoImage != nil, "Logo image was nil.")

            let file = AccountOnFile(json: ["id": 222, "paymentProductId": 1])!
            file.identifier = "222"
            item.accountsOnFile.accountsOnFile.append(file)
            XCTAssertTrue(item.accountOnFile(withIdentifier: "1") != nil, "Account on file was not found.")
            XCTAssertTrue(
                item.accountOnFile(withIdentifier: "1")!.paymentProductIdentifier == "3",
                "Payment product identifier incorrect."
            )

            XCTAssertTrue(item.accountOnFile(withIdentifier: "222") != nil, "Account on file was not found.")
            XCTAssertTrue(
                item.accountOnFile(withIdentifier: "9999") == nil,
                """
                Account on file should not have been found, identifier:
                \(String(describing: item.accountOnFile(withIdentifier: "9999")?.identifier)).
                """
            )

            let formatter = StringFormatter()

            guard let decimalRegex = try? NSRegularExpression(pattern: "[4-5]") else {
                XCTFail("Could not create Regular Expression")
                return
            }
            formatter.decimalRegex = decimalRegex

            item.stringFormatter = formatter
            for file in item.accountsOnFile.accountsOnFile {
                XCTAssertTrue(
                    file.stringFormatter.decimalRegex.pattern == "[4-5]",
                    "Decimal regex should have been: [4-5], but was: \(file.stringFormatter.decimalRegex.pattern)"
                )
                XCTAssertTrue(
                    file.stringFormatter.decimalRegex.pattern != "[0-0]",
                    "Decimal regex should have not been: \(file.stringFormatter.decimalRegex.pattern)"
                )
            }
        }

        XCTAssertTrue(
            paymentItems.accountsOnFile.first != nil,
            "Accounts on file should have been added in the for-loop above."
        )
    }

    func allPaymentItems(basicItems: [BasicPaymentItem]) {
        var index = 1
        for item in basicItems {
            for file in item.accountsOnFile.accountsOnFile {
                if let labelTemp = file.displayHints.labelTemplate.labelTemplateItems.first {
                    XCTAssertTrue(labelTemp.attributeKey == "17", "Attribute key incorrect.")
                    XCTAssertTrue(labelTemp.mask == "12345", "Mask incorrect.")
                    XCTAssertTrue(!file.label.isEmpty, "Label should not have been empty.")

                    XCTAssertTrue(file.attributes.attributes.count > 0, "No attributes found.")

                } else {
                    XCTAssertTrue(file.label.isEmpty, "Label should have been empty.")
                }
            }
            if let product = item as? BasicPaymentProduct {
                XCTAssertTrue(product.identifier == "\(index)", "Identifier was incorrect.")
                XCTAssertTrue(
                    product.displayHints.displayOrder != nil,
                    "Display order was nil (\(String(describing: product.displayHints.displayOrder)))."
                )
                XCTAssertTrue(product.allowsTokenization, "Tokenization was false.")
                XCTAssertTrue(product.allowsRecurring, "Recurring was false.")
                XCTAssertTrue(product.paymentMethod == "card", "Payment method was not card.")
                XCTAssertTrue(product.paymentProductGroup == "cards", "Payment group was not cards.")
            }
            index += 1
        }
    }

}
