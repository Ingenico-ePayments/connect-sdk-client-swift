//
//  C2SCommunicatorTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import IngenicoConnectKit

class C2SCommunicatorTestCase: XCTestCase {

    var communicator: C2SCommunicator!
    var configuration: C2SCommunicatorConfiguration!
    let context =
        PaymentContext(
            amountOfMoney: PaymentAmountOfMoney(totalAmount: 3, currencyCode: "EUR"),
            isRecurring: true,
            countryCode: "NL"
        )

    var applePaymentProduct: BasicPaymentProduct!

    override func setUp() {
        super.setUp()

        let applePaymentProductJSON = Data("""
        {
            "fields": [],
            "id": \(Int(SDKConstants.kApplePayIdentifier)!),
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)

        applePaymentProduct = try? JSONDecoder().decode(BasicPaymentProduct.self, from: applePaymentProductJSON)

        let androidPaymentProductJSON = Data("""
        {
            "fields": [],
            "id": \(Int(SDKConstants.kAndroidPayIdentifier)!),
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)

        _ = try? JSONDecoder().decode(BasicPaymentProduct.self, from: androidPaymentProductJSON)

        configuration =
            C2SCommunicatorConfiguration(
                clientSessionId: "1",
                customerId: "1",
                baseURL: "https://ams1.sandbox.api-ingenico.com/client/v1",
                assetBaseURL: "https://ams1.sandbox.api-ingenico.com/client/v1",
                appIdentifier: "",
                ipAddress: ""
            )
        communicator = C2SCommunicator(configuration: configuration)
    }

    func testApplePayAvailabilityWithoutApplePay() {
        let paymentProducts = BasicPaymentProducts()

        let expectation = self.expectation(description: "Response provided")

        _ = communicator.checkApplePayAvailability(with: paymentProducts, for: context, success: {
            expectation.fulfill()
        }, failure: { (error) in
            XCTFail(
                "Unexpected failure while testing applePayAvailabilityWithoutApplePay: \(error.localizedDescription)"
            )
        }, apiFailure: { errorResponse in
            XCTFail(
                """
                Unexpected failure while testing applePayAvailabilityWithoutApplePay: \(errorResponse.errors[0].message)
                """
            )
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testApplePayAvailabilityWithApplePay() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
             let response = [
                "networks": [ "amex", "discover", "masterCard", "visa" ]
             ]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let paymentProducts = BasicPaymentProducts()
        paymentProducts.paymentProducts.append(applePaymentProduct)

        let expectation = self.expectation(description: "Response provided")

        _ = communicator.checkApplePayAvailability(with: paymentProducts, for: context, success: {
            expectation.fulfill()

        }, failure: { (error) in
            XCTFail("Unexpected failure while testing checkApplePayAvailability: \(error.localizedDescription)")
        }, apiFailure: { errorResponse in
            XCTFail("Unexpected failure while testing checkApplePayAvailability: \(errorResponse.errors[0].message)")
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductForContext() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
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
                        "paymentProductGroup": "cards"
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

        let context =
            PaymentContext(
                amountOfMoney: PaymentAmountOfMoney(totalAmount: 3, currencyCode: "EUR"),
                isRecurring: true,
                countryCode: "NL"
            )
        let expectation = self.expectation(description: "Response provided")

        communicator.paymentProducts(forContext: context, success: { _ in
            expectation.fulfill()
        }, failure: { error in
            XCTFail("Unexpected failure while testing paymentProductForContext: \(error.localizedDescription)")
        }, apiFailure: { errorResponse in
            XCTFail("Unexpected failure while testing paymentProductForContext: \(errorResponse.errors[0].message)")
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }

    }

    func testPublicKey() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
            // swiftlint:disable line_length
            let response = [
                "keyId": "86b64e4e-f43e-4a27-9863-9bbd5b499f82",
                "publicKey":
                """
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkiJlGL1QjUnGDLpMNBtZPYVtOU121jfFcV4WrZayfw9Ib/1AtPBHP/0ZPocdA23zDh6aB+QiOQEkHZlfnelBNnEzEu4ibda3nDdjSrKveSiQPyB5X+u/IS3CR48B/g4QJ+mcMV9hoFt6Hx3R99A0HWMs4um8elQsgB11MsLmGb1SuLo0S1pgL3EcckXfBDNMUBMQ9EtLC9zQW6Y0kx6GFXHgyjNb4yixXfjo194jfhei80sVQ49Y/SHBt/igATGN1l18IBDtO0eWmWeBckwbNkpkPLAvJfsfa3JpaxbXwg3rTvVXLrIRhvMYqTsQmrBIJDl7F6igPD98Y1FydbKe5QIDAQAB
                """
                ]
            // swiftlint:enable line_length
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")

        communicator.publicKey(success: { (publicKeyResponse) in
            expectation.fulfill()

            XCTAssertEqual(
                publicKeyResponse.keyId,
                "86b64e4e-f43e-4a27-9863-9bbd5b499f82",
                "Received keyId not as expected"
            )
            // swiftlint:disable line_length
            XCTAssertEqual(
                publicKeyResponse.encodedPublicKey,
                """
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkiJlGL1QjUnGDLpMNBtZPYVtOU121jfFcV4WrZayfw9Ib/1AtPBHP/0ZPocdA23zDh6aB+QiOQEkHZlfnelBNnEzEu4ibda3nDdjSrKveSiQPyB5X+u/IS3CR48B/g4QJ+mcMV9hoFt6Hx3R99A0HWMs4um8elQsgB11MsLmGb1SuLo0S1pgL3EcckXfBDNMUBMQ9EtLC9zQW6Y0kx6GFXHgyjNb4yixXfjo194jfhei80sVQ49Y/SHBt/igATGN1l18IBDtO0eWmWeBckwbNkpkPLAvJfsfa3JpaxbXwg3rTvVXLrIRhvMYqTsQmrBIJDl7F6igPD98Y1FydbKe5QIDAQAB
                """,
                "Received publicKey not as expected"
            )
            // swiftlint:enable line_length
        }, failure: { (error) in
            XCTFail("Unexpected failure while testing publicKey: \(error.localizedDescription)")
        }, apiFailure: { errorResponse in
            XCTFail("Unexpected failure while testing publicKey: \(errorResponse.errors[0].message)")
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductGroupsForContext() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
            let response = [
                "paymentProductGroups": [
                    [
                            "displayHints": [
                                "displayOrder": 20,
                                "label": "Cards",
                                "logo": "/templates/master/global/css/img/ppimages/group-card.png"
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

        communicator.paymentProductGroups(forContext: context, success: { (groups) in
            expectation.fulfill()

            if let group = groups.paymentProductGroups.first {
                XCTAssertEqual(group.identifier, "cards", "Received group id not as expected")
                XCTAssertEqual(group.displayHints.displayOrder, 20, "Received group displayOrder not as expected")
                XCTAssertEqual(
                    group.displayHints.logoPath,
                    "/templates/master/global/css/img/ppimages/group-card.png",
                    "Received group logoPath not as expected"
                )
            } else {
                XCTFail("Received group not as expected")
            }

        }, failure: { (error) in
            XCTFail("Unexpected failure while testing paymentProductGroupsForContext: \(error.localizedDescription)")
        }, apiFailure: { errorResponse in
            XCTFail(
                """
                Unexpected failure while testing paymentProductGroupsForContext: \(errorResponse.errors[0].message)
                """
            )
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductWithId() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
            let response = [
                "paymentProductGroups": [
                    [
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Cards",
                            "logo": "/templates/master/global/css/img/ppimages/group-card.png"
                        ],
                        "id": "cards"
                    ]
                ],
                "allowsRecurring": true,
                "allowsTokenization": true,
                "displayHints": [
                    "displayOrder": 20,
                    "label": "Visa",
                    "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
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
                                "type": "text",
                                "valueMapping": [
                                    [
                                        "displayName": "Value map display",
                                        "value": "Value map value"
                                    ],
                                    [
                                        "displayName": "Value map display 2",
                                        "value": "Value map value 2"
                                    ]
                                ]
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

        communicator.paymentProduct(withIdentifier: "1", context: context, success: { (paymentProduct) in
            expectation.fulfill()

            let product = paymentProduct
            XCTAssertEqual(product.identifier, "1", "Received product id not as expected")
            XCTAssertEqual(product.displayHints.displayOrder, 20, "Received product displayOrder not as expected")
            XCTAssertEqual(
                product.displayHints.logoPath,
                "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png",
                "Received product logoPath not as expected"
            )

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
                FormElementType.textType,
                "Received product field displayHints formElement type not as expected"
            )
            XCTAssertTrue(field.displayHints.formElement.valueMapping.count > 0, "No Value map found.")

        }, failure: { (error) in
            XCTFail("Unexpected failure while testing paymentProductWithId: \(error.localizedDescription)")
        }, apiFailure: { errorResponse in
            XCTFail("Unexpected failure while testing paymentProductWithId: \(errorResponse.errors[0].message)")
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductGroupWithId() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
            let response = [
                    "displayHints": [
                        "displayOrder": 20,
                        "label": "Cards",
                        "logo": "/templates/master/global/css/img/ppimages/group-card.png"
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
                                    "image": "/templates/master/global/css/img/ppimages/ppf_cvv_v1.png",
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
        communicator.paymentProductGroup(withIdentifier: "1", context: context, success: { paymentProductGroup in
            self.check(paymentProductGroup: paymentProductGroup)

            expectation.fulfill()
        }, failure: { (_) in
            XCTFail("Product group with id failed.")
            expectation.fulfill()
        }, apiFailure: { errorResponse in
            XCTFail(
                """
                Unexpected failure while testing testPaymentProductNetworksForProductId:
                \(errorResponse.errors[0].message)
                """
            )
        })
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    private func check(paymentProductGroup: PaymentProductGroup) {
        XCTAssertEqual(paymentProductGroup.identifier, "cards")
        XCTAssertEqual(paymentProductGroup.displayHints.displayOrder, 20)
        XCTAssertEqual(paymentProductGroup.displayHints.label, "Cards")
        XCTAssertEqual(
            paymentProductGroup.displayHints.logoPath,
            "/templates/master/global/css/img/ppimages/group-card.png"
        )
        XCTAssertEqual(paymentProductGroup.fields.paymentProductFields.count, 3)
        XCTAssertEqual(paymentProductGroup.accountsOnFile.accountsOnFile.count, 0)
    }

    func testPaymentProductNetworksForProductId() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
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
        communicator.paymentProductNetworks(forProduct: "1", context: context, success: { paymentProductNetworks in
            self.check(paymentProductNetworks: paymentProductNetworks)

            expectation.fulfill()
        }, failure: { (error) in
            XCTFail(
                "Unexpected failure while testing testPaymentProductNetworksForProductId: \(error.localizedDescription)"
            )
            expectation.fulfill()
        }, apiFailure: { errorResponse in
            XCTFail(
                """
                Unexpected failure while testing testPaymentProductNetworksForProductId:
                \(errorResponse.errors[0].message)
                """
            )
        })

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

    func testPaymentProductIdByPartialCreditCardNumber() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
            let response = [
                "countryCode": "RU",
                "paymentProductId": 3
                ] as [String: Any]
            return
                HTTPStubsResponse(
                    jsonObject: response,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")

        communicator.paymentProductId(
            byPartialCreditCardNumber: "520953",
            context: context,
            success: { (gciinDetailsResponse) in
                expectation.fulfill()

                XCTAssertEqual(gciinDetailsResponse.countryCodeString, "RU", "Received countrycode not as expected")
                XCTAssertEqual(gciinDetailsResponse.paymentProductId, "3", "Received paymentProductId not as expected")
            },
            failure: { (error) in
                XCTFail(
                    """
                    Unexpected failure while testing paymentProductWithIdPartialCreditCard:
                    \(error.localizedDescription)
                    """
                )
            },
            apiFailure: { errorResponse in
                XCTFail(
                    """
                    Unexpected failure while testing paymentProductWithIdPartialCreditCard:
                    \(errorResponse.errors[0].message)
                    """
                )
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testConvertAmount() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
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

        communicator.convert(
            amountInCents: 3,
            source: "EUR",
            target: "USD",
            success: { (convertedAmountResponse: ConvertedAmountResponse) in
                expectation.fulfill()

                XCTAssertEqual(convertedAmountResponse.convertedAmount, 138, "Received convertedAmount not as expected")
            },
            failure: { (error) in
                XCTFail(
                    "Unexpected failure while testing convertAmount: \(String(describing: error?.localizedDescription))"
                )
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected failure while testing convertAmount: \(errorResponse.errors[0].message)")
            }
        )

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testConvertAmountNotWorking() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
            return HTTPStubsResponse(jsonObject: [], statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        let expectation = self.expectation(description: "Response provided")

        communicator.convert(amountInCents: 3, source: "EUR", target: "USD", success: { (_: ConvertedAmountResponse) in
            expectation.fulfill()
            XCTFail("Unexpected success")
        }, failure: { _ in
            expectation.fulfill()
        }, apiFailure: { _ in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testDirectoryForPaymentProductId() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
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

        communicator.directory(forProduct: "", countryCode: "NL", currencyCode: "EUR", success: { (directoryEntries) in

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
            XCTAssertEqual(entries[1].issuerName, "ASN Bank", "Received issuerName of directoryEntry not as expected")

            expectation.fulfill()
        }, failure: { (error) in
            XCTFail("Unexpected failure while testing directoryForPaymentProductId: \(error.localizedDescription)")
        }, apiFailure: { errorResponse in
            XCTFail("Unexpected failure while testing directoryForPaymentProductId: \(errorResponse.errors[0].message)")
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }

    }

    func testDirectoryFail() {
        stub(condition: isHost("ams1.sandbox.api-ingenico.com")) { _ in
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
                    statusCode: 403,
                    headers: ["Content-Type": "application/json"]
                )
        }

        let expectation = self.expectation(description: "Response provided")

        communicator.directory(forProduct: "", countryCode: "NL", currencyCode: "EUR", success: { (_) in
            XCTFail("Unexpected success.")
            expectation.fulfill()
        }, failure: { (error) in
            XCTAssertEqual(
                error.localizedDescription,
                "Response status code was unacceptable: 403.",
                "Response validation failed expected."
            )
            expectation.fulfill()
        }, apiFailure: { errorResponse in
            XCTAssertEqual(
                errorResponse.errors[0].message,
                "Response status code was unacceptable: 403.",
                "Response validation failed expected."
            )
            expectation.fulfill()
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testIINPartialCreditCardNumberLogic() {
        // Test that a partial CC of length 6 returns 6 IIN digits
        let result1 = communicator.getIINDigitsFrom(partialCreditCardNumber: "123456")
        XCTAssertEqual(result1, "123456", "Expected: '123456', actual: \(result1)")

        // Test that a partial CC of length 7 returns 6 IIN digits
        let result2 = communicator.getIINDigitsFrom(partialCreditCardNumber: "1234567")
        XCTAssertEqual(result2, "123456", "Expected: '123456', actual: \(result2)")

        // Test that a partial CC of length 8 returns 8 IIN digits
        let result3 = communicator.getIINDigitsFrom(partialCreditCardNumber: "12345678")
        XCTAssertEqual(result3, "12345678", "Expected: '12345678', actual: \(result3)")

        // Test that a partial CC of length less than 6 returns the provided digits
        let result4 = communicator.getIINDigitsFrom(partialCreditCardNumber: "123")
        XCTAssertEqual(result4, "123", "Expected: '123', actual: \(result4)")

        // Test that an empty string does not crash
        let result5 = communicator.getIINDigitsFrom(partialCreditCardNumber: "")
        XCTAssertEqual(result5, "", "Expected: '', actual: \(result5)")

        // Test that a partial CC longer than 8 returns 8 IIN digits
        let result6 = communicator.getIINDigitsFrom(partialCreditCardNumber: "12345678112")
        XCTAssertEqual(result6, "12345678", "Expected: '123456', actual: \(result6)")
    }
}
