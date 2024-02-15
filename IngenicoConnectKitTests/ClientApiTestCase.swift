//
//  ClientApiTestCase.swift
//  IngenicoConnectKitTests
//
//  Created for Ingenico ePayments on 28/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import IngenicoConnectKit

class ClientApiTestCase: XCTestCase {
    let host = "ams1.sandbox.api-ingenico.com"

    let sdkConfiguration = ConnectSDKConfiguration(
        sessionConfiguration: SessionConfiguration(
            clientSessionId: "client-session-id",
            customerId: "customer-id",
            clientApiUrl: "https://ams1.sandbox.api-ingenico.com/client/v1",
            assetUrl: "https://ams1.sandbox.api-ingenico.com/client/v1/assets"
        ),
        enableNetworkLogs: false,
        applicationId: "application-id",
        ipAddress: "ip-address",
        preLoadImages: true
    )

    let paymentConfiguration = PaymentConfiguration(
        paymentContext: PaymentContext(
            amountOfMoney: PaymentAmountOfMoney(totalAmount: 3, currencyCode: "EUR"),
            isRecurring: true,
            countryCode: "NL"
        ),
        groupPaymentProducts: true
    )

    var stubClientApi: StubClientApi!

    override func setUp() {
        super.setUp()

        stubClientApi = StubClientApi(sdkConfiguration: sdkConfiguration, paymentConfiguration: paymentConfiguration)
    }

    func testPaymentProducts() {
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/products") && isMethodGET()) { _ in
            let response = [
                "paymentProducts": [
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Visa",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                        ],
                        "id": 1,
                        "maxAmount": 1000000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards"
                    ],
                    [
                        "allowsRecurring": true,
                        "allowsTokenization": true,
                        "displayHints": [
                            "displayOrder": 19,
                            "label": "American Express",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_2_v1.png"
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
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_3_v1.png"
                        ],
                        "id": 3,
                        "maxAmount": 1000000,
                        "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                        "paymentMethod": "card",
                        "paymentProductGroup": "cards"
                    ]
                ]
            ]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")
        stubClientApi.paymentProducts(
            success: { _ in
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure during testPaymentProducts: \(error.localizedDescription)")
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected api failure during testPaymentProducts: \(errorResponse.errors[0].message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductNetworks() {
        stub(condition: isHost(host)) { _ in
            let response = [
                "networks": ["Visa", "MasterCard"]
            ] as [String: Any]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")
        stubClientApi.paymentProductNetworks(
            forProduct: "1",
            success: { paymentProductNetworks in
                self.check(paymentProductNetworks: paymentProductNetworks)

                expectation.fulfill()
            },
            failure: { error in
                XCTFail(
                    "Unexpected failure during testPaymentProductNetworks: \(error.localizedDescription)"
                )
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail(
                    "Unexpected api failure during testPaymentProductNetworks: \(errorResponse.errors[0].message)"
                )
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    private func check(paymentProductNetworks: PaymentProductNetworks) {
        XCTAssertEqual(paymentProductNetworks.paymentProductNetworks.count, 2)
        XCTAssertEqual(paymentProductNetworks.paymentProductNetworks[0].rawValue, "Visa")
        XCTAssertEqual(paymentProductNetworks.paymentProductNetworks[1].rawValue, "MasterCard")
    }

    func testPaymentProductWithId() {
        stub(condition: isHost(host)) { _ in
            let response = [
                "paymentProductGroups": [
                    [
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Cards",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/group-card.png"
                        ],
                        "id": "cards"
                    ]
                ],
                "allowsRecurring": true,
                "allowsTokenization": true,
                "displayHints": [
                    "displayOrder": 20,
                    "label": "Visa",
                    "logo": "https://example.com/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
                ],
                "fields": [
                    [
                        "dataRestrictions": [
                            "isRequired": true,
                            "validators": [
                                "length": [
                                    "maxLength": 19,
                                    "minLength": 12
                                ],
                                "luhn": [

                                ], "expirationDate": [

                                ],
                                  "regularExpression": [
                                    "regularExpression": "(?:0[1-9]|1[0-2])[0-9]{2}"
                                ]
                            ]
                        ],
                        "displayHints": [
                            "displayOrder": 10,
                            "formElement": [
                                "type": "currency"
                            ],
                            "label": "Card number:",
                            "mask": "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                            "obfuscate": false,
                            "placeholderLabel": "**** **** **** ****",
                            "preferredInputType": "IntegerKeyboard"
                        ],
                        "id": "cardNumber",
                        "type": "numericstring"
                    ]
                ],
                "id": 1,
                "maxAmount": 1000000,
                "mobileIntegrationLevel": "OPTIMISED_SUPPORT",
                "paymentMethod": "card",
                "paymentProductGroup": "cards"
            ] as [String: Any]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")

        stubClientApi.paymentProduct(
            withId: "1",
            success: { product in
                self.check(paymentProduct: product)

                // Check initializeImages
                for index in 0..<product.fields.paymentProductFields.count {
                    let field = product.fields.paymentProductFields[index]

                    // Should analyse why imagePath is never set in JSON conversion.
                    // And add test that tests the behavior when it is set.
                    if field.displayHints.tooltip?.imagePath != nil {
                        XCTAssertNotNil(field.displayHints.tooltip?.image, "Tooltip image was nil")
                    }
                }
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure during testPaymentProductWithId: \(error.localizedDescription)")
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected api failure during testPaymentProductWithId: \(errorResponse.errors[0].message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    private func check(paymentProduct product: PaymentProduct) {
        XCTAssertEqual(product.identifier, "1", "Received product id not as expected")
        XCTAssertEqual(product.displayHints.displayOrder, 20, "Received product displayOrder not as expected")
        XCTAssertEqual(
            product.displayHints.logoPath,
            "https://example.com/templates/master/global/css/img/ppimages/pp_logo_1_v1.png",
            "Received product logoPath not as expected"
        )
        XCTAssertNotNil(product.displayHints.logoImage, "Logo image was nil")

        guard let field = product.fields.paymentProductFields.first else {
            XCTFail("Received product field not as expected")
            return
        }

        // Data Restrictions
        XCTAssertEqual(field.dataRestrictions.isRequired, true, "Received product field isRequired not as expected")
        guard let lengthValidator = field.dataRestrictions.validators.validators[2] as? ValidatorLength else {
            XCTFail("Received product field length validator not as expected")
            return
        }
        XCTAssertEqual(
            lengthValidator.maxLength,
            19,
            "Received product field length validator maxlength not as expected"
        )
        XCTAssertEqual(
            lengthValidator.minLength,
            12,
            "Received product field length validator minLength not as expected"
        )
        XCTAssertEqual(
            field.dataRestrictions.validators.validators.count,
            4,
            "Received product fields count not as expected"
        )

        // Display Hints
        XCTAssertEqual(
            field.displayHints.displayOrder,
            10,
            "Received product field displayHints displayOrder not as expected"
        )
        XCTAssertEqual(
            field.displayHints.mask,
            "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
            "Received product field displayHints mask not as expected"
        )
        XCTAssertEqual(
            field.displayHints.obfuscate,
            false,
            "Received product field displayHints obfuscate not as expected"
        )
        XCTAssertEqual(
            field.displayHints.preferredInputType,
            PreferredInputType.integerKeyboard,
            "Received product field displayHints preferredInputType not as expected"
        )
        XCTAssertEqual(
            field.displayHints.formElement.type,
            FormElementType.currencyType,
            "Received product field displayHints formElement type not as expected"
        )
    }

    func testIinDetailsForPartialCreditCardNumber() {
        _ = PaymentAmountOfMoney(totalAmount: 0, currencyCode: "EUR")

        stub(condition: isHost(host)) { _ in
            let response = [
                "countryCode": "RU",
                "paymentProductId": 3,
                "isAllowedInContext": true
                ] as [String: Any]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        // Test too short partial credit card number
        var expectation = self.expectation(description: "Response provided")
        stubClientApi.iinDetails(
            forPartialCreditCardNumber: "01234",
            success: { iinDetailsResponse in
                XCTAssertEqual(iinDetailsResponse.status.hashValue, IINStatus.notEnoughDigits.hashValue)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail(
                    """
                    Unexpected failure during testIinDetailsForPartialCreditCardNumber: \(error.localizedDescription)
                    """
                )
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail(
                    """
                    Unexpected api failure during testIinDetailsForPartialCreditCardNumber:
                    \(errorResponse.errors[0].message)
                    """
                )
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }

        // Test a successful response
        expectation = self.expectation(description: "Response provided")
        stubClientApi.iinDetails(
            forPartialCreditCardNumber: "012345",
            success: { iinDetailsResponse in
                XCTAssertEqual(iinDetailsResponse.status.hashValue, IINStatus.supported.hashValue)
                XCTAssertEqual(iinDetailsResponse.countryCodeString, "RU")
                XCTAssertEqual(iinDetailsResponse.paymentProductId, "3")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail(
                    """
                    Unexpected failure during testIinDetailsForPartialCreditCardNumber: \(error.localizedDescription)
                    """
                )
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail(
                    """
                    Unexpected api failure during testIinDetailsForPartialCreditCardNumber:
                    \(errorResponse.errors[0].message)
                    """
                )
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }

        // Test a pending request
        expectation = self.expectation(description: "Response provided")
        stubClientApi.iinLookupPending = true
        stubClientApi.iinDetails(
            forPartialCreditCardNumber: "012345",
            success: { iinDetailsResponse in
                XCTAssertEqual(iinDetailsResponse.status.hashValue, IINStatus.pending.hashValue)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail(
                    """
                    Unexpected failure during testIinDetailsForPartialCreditCardNumber: \(error.localizedDescription)
                    """
                )
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail(
                    """
                    Unexpected api failure during testIinDetailsForPartialCreditCardNumber:
                    \(errorResponse.errors[0].message)
                    """
                )
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testConvertAmount() {
        stub(condition: isHost(host)) { _ in
            let response = [
                "convertedAmount": 138
            ]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")

        stubClientApi.convert(
            amountInCents: 3,
            sourceCurrency: "EUR",
            targetCurrency: "USD",
            success: { (convertedAmountResponse: ConvertedAmountResponse) in
                XCTAssertEqual(convertedAmountResponse.convertedAmount, 138, "Received convertedAmount not as expected")
                expectation.fulfill()

            },
            failure: { (error) in
                XCTFail("Unexpected failure during testConvertAmount: \(error.localizedDescription)")
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected api failure during testConvertAmount: \(errorResponse.errors[0].message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testDirectoryForPaymentProductId() {
        stub(condition: isHost(host)) { _ in
            let response = [
                "entries": [ [
                    "countryNames": [ "Nederland" ],
                    "issuerId": "ABNANL2A",
                    "issuerList": "short",
                    "issuerName": "ABN Amro Bank"
                    ], [
                        "countryNames": [ "Nederland" ],
                        "issuerId": "ASNBNL21",
                        "issuerList": "long",
                        "issuerName": "ASN Bank"
                    ] ]
                ]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")

        stubClientApi.directory(
            forProduct: "product-id",
            success: { directoryEntries in
                XCTAssertEqual(
                    directoryEntries.directoryEntries.count,
                    2,
                    "Received amount of directoryEntries not as expected"
                )
                let entries = directoryEntries.directoryEntries

                XCTAssertEqual(
                    entries[0].countryNames.count,
                    1,
                    "Received amount of countryNames in DirectoryEntry not as expected"
                )
                XCTAssertEqual(
                    entries[0].issuerIdentifier,
                    "ABNANL2A",
                    "Received issuerID of directoryEntry not as expected"
                )
                XCTAssertEqual(entries[1].issuerList, "long", "Received issuerList of directoryEntry not as expected")
                XCTAssertEqual(
                    entries[1].issuerName,
                    "ASN Bank",
                    "Received issuerName of directoryEntry not as expected"
                )

                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure during testDirectoryForPaymentProductId: \(error.localizedDescription)")
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail(
                    "Unexpected api failure during testDirectoryForPaymentProductId: \(errorResponse.errors[0].message)"
                )
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductGroups() {
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/productgroups") && isMethodGET()) { _ in
            let response = [
                "paymentProductGroups": [
                    [
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Cards",
                            "logo": "https://example.com/templates/master/global/css/img/ppimages/group-card.png"
                        ],
                        "id": "cards",
                        "deviceFingerprintEnabled": true,
                        "allowsInstallments": false
                    ]
                ]
            ]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")
        stubClientApi.paymentProductGroups(
            success: { (groups) in
                XCTAssertTrue(groups.paymentProductGroups.count == 1, "Expected one group.")
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure during testPaymentProductGroups: \(error.localizedDescription)")
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected api failure during testPaymentProductGroups: \(errorResponse.errors[0].message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductGroup() {
        stub(condition: isHost(host) && isPath("/client/v1/customer-id/productgroups/1") && isMethodGET()) { _ in
            let response = [
                    "displayHints": [
                        "displayOrder": 20,
                        "label": "Cards",
                        "logo": "https://example.com/templates/master/global/css/img/ppimages/group-card.png"
                    ],
                    "fields": [[
                        "dataRestrictions": [
                            "isRequired": true,
                            "validators": [
                                "length": [
                                    "maxLength": 19,
                                    "minLength": 12
                                ],
                                "luhn": [

                                ]
                            ]
                        ],
                        "displayHints": [
                            "displayOrder": 10,
                            "formElement": [
                                "type": "text"
                            ],
                            "label": "Card number:",
                            "mask": "[[9999]] [[9999]] [[9999]] [[9999]] [[999]]",
                            "obfuscate": false,
                            "placeholderLabel": "**** **** **** ****",
                            "preferredInputType": "IntegerKeyboard"
                        ],
                        "id": "cardNumber",
                        "type": "numericstring"
                        ], [
                            "dataRestrictions": [
                                "isRequired": true,
                                "validators": [
                                    "expirationDate": [

                                    ],
                                    "length": [
                                        "maxLength": 4,
                                        "minLength": 4
                                    ],
                                    "regularExpression": [
                                        "regularExpression": "(?:0[1-9]|1[0-2])[0-9][2]"
                                    ]
                                ]
                            ],
                            "displayHints": [
                                "displayOrder": 20,
                                "formElement": [
                                    "type": "text"
                                ],
                                "label": "Expiry date:",
                                "mask": "[[99]]/[[99]]",
                                "obfuscate": false,
                                "placeholderLabel": "MM/YY",
                                "preferredInputType": "IntegerKeyboard"
                            ],
                            "id": "expiryDate",
                            "type": "expirydate"
                        ], [
                            "dataRestrictions": [
                                "isRequired": false,
                                "validators": [
                                    "length": [
                                        "maxLength": 4,
                                        "minLength": 3
                                    ],
                                    "regularExpression": [
                                        "regularExpression": "^[0-9][3][0-9]?$"
                                    ]
                                ]
                            ],
                            "displayHints": [
                                "displayOrder": 24,
                                "formElement": [
                                    "type": "text"
                                ],
                                "label": "CVV:",
                                "mask": "[[9999]]",
                                "obfuscate": false,
                                "placeholderLabel": "123",
                                "preferredInputType": "IntegerKeyboard",
                                "tooltip": [
                                    "image":
                                        "https://example.com/templates/master/global/css/img/ppimages/ppf_cvv_v1.png",
                                    "label": "The CVV is a 3 or 4 digit code embossed or imprinted on your card."
                                ]
                            ],
                            "id": "cvv",
                            "type": "numericstring"
                        ]],
                    "id": "cards",
                    "deviceFingerprintEnabled": true,
                    "allowsInstallments": false
                ] as [String: Any]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")
        stubClientApi.paymentProductGroup(
            withId: "1",
            success: { paymentProductGroup in
                self.check(paymentProductGroup: paymentProductGroup)
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected api failure during testPaymentProductGroup: \(error.localizedDescription)")
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected api failure during testPaymentProductGroup: \(errorResponse.errors[0].message)")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    private func check(paymentProductGroup group: PaymentProductGroup) {
        XCTAssertEqual(group.identifier, "cards", "Received group identifier not as expected")

        // Display Hints
        XCTAssertEqual(group.displayHints.displayOrder, 20, "Received group displayOrder not as expected")
        XCTAssertEqual(group.displayHints.label, "Cards", "Received group label not as expected")
        XCTAssertEqual(
            group.displayHints.logoPath,
            "https://example.com/templates/master/global/css/img/ppimages/group-card.png",
            "Received group logoPath not as expected"
        )
        XCTAssertNotNil(group.displayHints.logoImage, "Logo image was nil")

        guard let field = group.fields.paymentProductFields.first else {
            XCTFail("Received group product field does not exist")
            return
        }

        // Payment Product Field - Data Restrictions
        XCTAssertEqual(field.dataRestrictions.isRequired, true, "Received product field isRequired not as expected")
        XCTAssertEqual(
            field.dataRestrictions.validators.validators.count,
            2,
            "Received group product fields count not as expected"
        )
        guard let lengthValidator = field.dataRestrictions.validators.validators[1] as? ValidatorLength else {
            XCTFail("Received group product field length validator not as expected")
            return
        }
        XCTAssertEqual(
            lengthValidator.maxLength,
            19,
            "Received group product field length validator maxlength not as expected"
        )
        XCTAssertEqual(
            lengthValidator.minLength,
            12,
            "Received group product field length validator minLength not as expected"
        )

        // Payment Product Field - Display Hints
        XCTAssertEqual(
            field.displayHints.displayOrder,
            10,
            "Received group product field displayHints displayOrder not as expected"
        )
        XCTAssertEqual(
            field.displayHints.formElement.type,
            FormElementType.textType,
            "Received group product field displayHints formElement type not as expected"
        )
        XCTAssertEqual(
            field.displayHints.label,
            "Card number:",
            "Received group product field displayHints label not as expected"
        )
        XCTAssertEqual(
            field.displayHints.mask,
            "[[9999]] [[9999]] [[9999]] [[9999]] [[999]]",
            "Received group product field displayHints mask not as expected"
        )
        XCTAssertEqual(
            field.displayHints.obfuscate,
            false,
            "Received group product field displayHints obfuscate not as expected"
        )
        XCTAssertEqual(
            field.displayHints.placeholderLabel,
            "**** **** **** ****",
            "Received group product field displayHints placeholderLabel not as expected"
        )
        XCTAssertEqual(
            field.displayHints.preferredInputType,
            PreferredInputType.integerKeyboard,
            "Received group product field displayHints preferredInputType not as expected"
        )
    }

    func testFailure() {
        stub(condition: isHost(host)) { _ in
            return HTTPStubsResponse(jsonObject: [], statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let expectation = self.expectation(description: "Response provided")
        stubClientApi.paymentProductNetworks(forProduct: "1", success: { (_) in
            XCTFail("Should have jumped to the failure block.")
            expectation.fulfill()
        }, failure: { _ in
            expectation.fulfill()
        }, apiFailure: { _ in
            XCTFail("Should have jumped to the failure block.")
            expectation.fulfill()
        })
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testApiFailure() {
        stub(condition: isHost(host)) { _ in
            let apiFailureResponse = [
                "errorId": "99",
                "errors": [[
                    "category": "Test failure",
                    "code": "1",
                    "httpStatusCode": 403,
                    "id": "1",
                    "message": "You are not allowed to perform this call."
                ]]
                ] as [String: Any]
            return
                HTTPStubsResponse(
                    jsonObject: apiFailureResponse,
                    statusCode: 403,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")
        stubClientApi.paymentProductNetworks(
            forProduct: "1",
            success: { (_) in
                XCTFail("Should have jumped to the api failure block.")
                expectation.fulfill()
            },
            failure: { _ in
                XCTFail("Should have jumped to the api failure block.")
                expectation.fulfill()
            },
            apiFailure: { apiError in
                XCTAssertEqual(apiError.errorId, "99")
                XCTAssertEqual(apiError.errors[0].code, "1")
                XCTAssertEqual(apiError.errors[0].message, "You are not allowed to perform this call.")
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
}
