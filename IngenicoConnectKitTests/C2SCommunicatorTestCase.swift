//
//  C2SCommunicatorTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
import Mockingjay

@testable import IngenicoConnectKit

class C2SCommunicatorTestCase: XCTestCase {
    
    var communicator: C2SCommunicator!
    var configuration: C2SCommunicatorConfiguration!
    let context = PaymentContext(amountOfMoney: PaymentAmountOfMoney(totalAmount: 3, currencyCode: .EUR), isRecurring: true, countryCode: .NL)

    var applePaymentProduct: BasicPaymentProduct!
    var androidPaymentProduct: BasicPaymentProduct!

    override func setUp() {
        super.setUp()

        applePaymentProduct = BasicPaymentProduct(json: [
            "fields": [[:]],
            "id": Int(SDKConstants.kApplePayIdentifier)!,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ]
        ])!

        androidPaymentProduct = BasicPaymentProduct(json: [
            "fields": [[:]],
            "id": Int(SDKConstants.kAndroidPayIdentifier)!,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ]
        ])!
        
        configuration = C2SCommunicatorConfiguration(clientSessionId: "1", customerId: "1", region: Region.EU, environment: Environment.sandbox, appIdentifier: "", ipAddress: "")
        communicator = C2SCommunicator(configuration: configuration)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFilterAndroidPayFromProducts() {
        var paymentProducts = BasicPaymentProducts()
        paymentProducts.paymentProducts = [applePaymentProduct, androidPaymentProduct]
        paymentProducts = communicator.filterAndroidPayFromProducts(paymentProducts: paymentProducts)
        
        var correct = false
        if paymentProducts.paymentProducts.count == 1 {
            if let product = paymentProducts.paymentProducts.first {
                if product === applePaymentProduct {
                    correct = true
                }
            }
        }
    
        XCTAssert(correct, "filterAndroidPayFromProduct did not filter out Android properly")
    }
    
    func testApplePayAvailabilityWithoutApplePay() {
        let paymentProducts = BasicPaymentProducts()
        
        let androidProduct = PaymentProduct(json: [
            "fields": [[:]],
            "id": Int(SDKConstants.kAndroidPayIdentifier)!,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ]
        ])!
        paymentProducts.paymentProducts.append(androidProduct)
        
        let expectation = self.expectation(description: "Response provided")
        
        _ = communicator.checkApplePayAvailability(with: paymentProducts, for: context, success: {
            expectation.fulfill()
        }) { (error) in
            XCTFail("Unexpected failure while testing checkApplePayAvailability: \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    func testApplePayAvailabilityWithApplePay() {
        stub(everything,
             json([
                "networks" : [ "amex", "discover", "masterCard", "visa" ]
             ])
        )
        
        let paymentProducts = BasicPaymentProducts()
        paymentProducts.paymentProducts.append(applePaymentProduct)
        
        let expectation = self.expectation(description: "Response provided")
        
        _ = communicator.checkApplePayAvailability(with: paymentProducts, for: context, success: {
            expectation.fulfill()
            
        }) { (error) in
            XCTFail("Unexpected failure while testing checkApplePayAvailability: \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPaymentProductForContext() {
        stub(everything,
             json([
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
                ])
        )
        
        let context = PaymentContext(amountOfMoney: PaymentAmountOfMoney(totalAmount: 3, currencyCode: .EUR), isRecurring: true, countryCode: .NL)
        let expectation = self.expectation(description: "Response provided")
        
        communicator.paymentProducts(forContext: context, success: { responseObject in
            expectation.fulfill()
        }, failure: { error in
            XCTFail("Unexpected failure while testing paymentProductForContext: \(error.localizedDescription)")
        })
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
        
    }

    func testPublicKey() {
        stub(everything,
             json([
                "keyId": "86b64e4e-f43e-4a27-9863-9bbd5b499f82",
                "publicKey": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkiJlGL1QjUnGDLpMNBtZPYVtOU121jfFcV4WrZayfw9Ib/1AtPBHP/0ZPocdA23zDh6aB+QiOQEkHZlfnelBNnEzEu4ibda3nDdjSrKveSiQPyB5X+u/IS3CR48B/g4QJ+mcMV9hoFt6Hx3R99A0HWMs4um8elQsgB11MsLmGb1SuLo0S1pgL3EcckXfBDNMUBMQ9EtLC9zQW6Y0kx6GFXHgyjNb4yixXfjo194jfhei80sVQ49Y/SHBt/igATGN1l18IBDtO0eWmWeBckwbNkpkPLAvJfsfa3JpaxbXwg3rTvVXLrIRhvMYqTsQmrBIJDl7F6igPD98Y1FydbKe5QIDAQAB"
                
                ])
        )
        
        let expectation = self.expectation(description: "Response provided")
        
        communicator.publicKey(success: { (publicKeyResponse) in
            expectation.fulfill()
            
            XCTAssertEqual(publicKeyResponse.keyId,  "86b64e4e-f43e-4a27-9863-9bbd5b499f82", "Received keyId not as expected")
            XCTAssertEqual(publicKeyResponse.encodedPublicKey,  "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkiJlGL1QjUnGDLpMNBtZPYVtOU121jfFcV4WrZayfw9Ib/1AtPBHP/0ZPocdA23zDh6aB+QiOQEkHZlfnelBNnEzEu4ibda3nDdjSrKveSiQPyB5X+u/IS3CR48B/g4QJ+mcMV9hoFt6Hx3R99A0HWMs4um8elQsgB11MsLmGb1SuLo0S1pgL3EcckXfBDNMUBMQ9EtLC9zQW6Y0kx6GFXHgyjNb4yixXfjo194jfhei80sVQ49Y/SHBt/igATGN1l18IBDtO0eWmWeBckwbNkpkPLAvJfsfa3JpaxbXwg3rTvVXLrIRhvMYqTsQmrBIJDl7F6igPD98Y1FydbKe5QIDAQAB", "Received publicKey not as expected")
        }) { (error) in
            XCTFail("Unexpected failure while testing publicKey: \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    
    func testPaymentProductGroupsForContext() {
        stub(everything,
             json([
                "paymentProductGroups": [
                    [
                        "displayHints": [
                            "displayOrder": 20,
                            "label": "Cards",
                            "logo": "/templates/master/global/css/img/ppimages/group-card.png"
                        ],
                        "id": "cards"
                    ]
                ]
             ])
        )
        
        let expectation = self.expectation(description: "Response provided")
        
        communicator.paymentProductGroups(forContext: context, success: { (groups) in
            expectation.fulfill()
            
            if let group = groups.paymentProductGroups.first {
                XCTAssertEqual(group.identifier, "cards", "Received group id not as expected")
                XCTAssertEqual(group.displayHints.displayOrder, 20, "Received group displayOrder not as expected")
                XCTAssertEqual(group.displayHints.logoPath, "/templates/master/global/css/img/ppimages/group-card.png", "Received group logoPath not as expected")
            } else {
                XCTFail("Received group not as expected")
            }
        
        }) { (error) in
            XCTFail("Unexpected failure while testing paymentProductGroupsForContext: \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPaymentProductWithId() {
        // TODO: Merges two response stubs, need to find a way to make stubs specific for a url. (Does not work with get variables)
        stub(everything,
             json([
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

                                ],"expirationDate": [

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
                                "valueMapping":[
                                    [
                                        "displayName":"Value map display",
                                        "value":"Value map value"
                                    ],
                                    [
                                        "displayName":"Value map display 2",
                                        "value":"Value map value 2"
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
                ])
        )
        
        let expectation = self.expectation(description: "Response provided")

        communicator.paymentProduct(withIdentifier: "1", context: context, success: { (paymentProduct) in
            expectation.fulfill()
            
            let product = paymentProduct
            XCTAssertEqual(product.identifier, "1", "Received product id not as expected")
            XCTAssertEqual(product.displayHints.displayOrder, 20, "Received product displayOrder not as expected")
            XCTAssertEqual(product.displayHints.logoPath, "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png", "Received product logoPath not as expected")

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

            XCTAssertEqual(lengthValidator.maxLength, 19, "Received product field length validator maxlength not as expected")
            XCTAssertEqual(lengthValidator.minLength, 12, "Received product field length validator minLength not as expected")
            XCTAssertEqual(field.dataRestrictions.validators.validators.count, 4, "Received product fields count not as expected")
            
            // Display Hints
            XCTAssertEqual(field.displayHints.displayOrder, 10, "Received product field displayHints displayOrder not as expected")
            XCTAssertEqual(field.displayHints.mask, "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}", "Received product field displayHints mask not as expected")
            XCTAssertEqual(field.displayHints.obfuscate, false, "Received product field displayHints obfuscate not as expected")
            XCTAssertEqual(field.displayHints.preferredInputType, PreferredInputType.integerKeyboard, "Received product field displayHints preferredInputType not as expected")
            XCTAssertEqual(field.displayHints.formElement.type, FormElementType.textType, "Received product field displayHints formElement type not as expected")
            XCTAssertTrue(field.displayHints.formElement.valueMapping.count > 0, "No Value map found.")
            
            
        }) { (error) in
            XCTFail("Unexpected failure while testing paymentProductWithId: \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

    func testPaymentProductGroupWithId(){
        // TODO: still needs to be written
    }
    
    func testPaymentProductIdByPartialCreditCardNumber() {
        stub(everything,
             json([
                "countryCode": "RU",
                "paymentProductId": 3
                ])
        )
        
        let expectation = self.expectation(description: "Response provided")
        
        communicator.paymentProductId(byPartialCreditCardNumber: "520953", context: context, success: { (gciinDetailsResponse) in
            expectation.fulfill()
            
            XCTAssertEqual(gciinDetailsResponse.countryCode, .RU, "Received countrycode not as expected")
            XCTAssertEqual(gciinDetailsResponse.paymentProductId, "3", "Received paymentProductId not as expected")
        }) { (error) in
            XCTFail("Unexpected failure while testing paymentProductWithIdPartialCreditCard: \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    func testConvertAmount() {
        stub(everything,
             json([
                "convertedAmount": 138
                ])
        )
        
        let expectation = self.expectation(description: "Response provided")
        
        communicator.convert(amountInCents: 3, source: .EUR, target: .USD, success: { (amount) in
            expectation.fulfill()
            
            XCTAssertEqual(amount, 138, "Received convertedAmount not as expected")
        }) { (error) in
            XCTFail("Unexpected failure while testing convertAmount: \(String(describing: error?.localizedDescription))")
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    func testConvertAmountNotWorking() {
        stub(everything,
             json([
                ])
        )
        
        let expectation = self.expectation(description: "Response provided")
        
        communicator.convert(amountInCents: 3, source: .EUR, target: .USD, success: { (amount) in
            expectation.fulfill()
            
            XCTFail("Unexpected success")
        }) { (error) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
    
    func testDirectoryForPaymentProductId() {
        stub(everything,
             json([
                "entries" : [ [
                    "countryNames" : [ "Nederland" ],
                    "issuerId" : "ABNANL2A",
                    "issuerList" : "short",
                    "issuerName" : "ABN Amro Bank"
                    ], [
                        "countryNames" : [ "Nederland" ],
                        "issuerId" : "ASNBNL21",
                        "issuerList" : "long",
                        "issuerName" : "ASN Bank"
                    ] ]
                ])
        )
        
        let expectation = self.expectation(description: "Response provided")
        
        communicator.directory(forProduct: "", countryCode: .NL, currencyCode: .EUR, success: { (directoryEntries) in

            XCTAssertEqual(directoryEntries.directoryEntries.count, 2, "Received amount of directoryEntries not as expected")
            let entries = directoryEntries.directoryEntries
            XCTAssertEqual(entries[0].countryNames.count, 1, "Received amount of countryNames in DirectoryEntry not as expected")
            XCTAssertEqual(entries[0].issuerIdentifier,  "ABNANL2A", "Received issuerID of directoryEntry not as expected")
            XCTAssertEqual(entries[1].issuerList,  "long", "Received issuerList of directoryEntry not as expected")
            XCTAssertEqual(entries[1].issuerName,  "ASN Bank", "Received issuerName of directoryEntry not as expected")

            expectation.fulfill()
        }) { (error) in
            XCTFail("Unexpected failure while testing directoryForPaymentProductId: \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func testDirectoryFail() {
        let expectation = self.expectation(description: "Response provided")
        
        communicator.directory(forProduct: "", countryCode: .NL, currencyCode: .EUR, success: { (directoryEntries) in
            XCTFail("Unexpected success.")
            expectation.fulfill()
        }) { (error) in
            XCTAssertTrue(error.localizedDescription == "Response status code was unacceptable: 403.", "Response validation failed expected.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
}












