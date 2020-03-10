//
//  PaymentRequestTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import IngenicoConnectKit

class PaymentRequestTestCase: XCTestCase {

    let request = PaymentRequest(paymentProduct: PaymentProduct(json: [
        "fields": [[:]],
        "id": 1,
        "paymentMethod": "card",
        "displayHints": [
            "displayOrder": 20,
            "label": "Visa",
            "logo": "/this/is_a_test.png"
        ]
    ])!)
    let account = AccountOnFile(json: ["id": 1, "paymentProductId": 1])!
    let fieldId = "1"
    var attribute: AccountOnFileAttribute!
    var session = Session(clientSessionId: "client-session-id",
                          customerId: "customer-id",
                          region: .EU,
                          environment: .sandbox,
                          appIdentifier: "")

    override func setUp() {
        super.setUp()

        attribute = AccountOnFileAttribute(json: ["key": fieldId, "value": "paymentProductFieldValue1", "status": "CAN_WRITE"])!

        account.attributes = AccountOnFileAttributes()
        account.attributes.attributes.append(attribute)
        request.accountOnFile = account

        request.paymentProduct = PaymentProduct(json: [
            "fields": [[:]],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            ]
        ])!

        let field = PaymentProductField(json: [
            "displayHints": [
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": fieldId,
            "type": "numericstring"
        ])!
        request.paymentProduct?.fields.paymentProductFields.append(field)
        request.paymentProduct?.paymentProductField(withId: fieldId)?.displayHints.mask = "{{9999}} {{9999}} {{9999}} {{9999}} {{9999}}"
        request.setValue(forField: field.identifier, value: "payment1Value")
        request.formatter = StringFormatter()

        request.validate()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetValue() {
        let value = request.getValue(forField: attribute.key)
        XCTAssertTrue(value != nil, "Did not find value of existing attribute.")

        XCTAssertTrue(request.getValue(forField: "9999") == nil, "Should have been nil: \(request.getValue(forField: "9999")!).")

        XCTAssertTrue(request.getValue(forField: fieldId) == "payment1Value", "Value not found.")
    }

    func testMaskedValue() {
        let value = request.maskedValue(forField: attribute.key)
        XCTAssertTrue(value != nil, "Value was not yet.")

        //TODO: Test masked value
        request.paymentProduct?.paymentProductField(withId: fieldId)?.displayHints.mask = "[[9999]] [[9999]] [[9999]] [[9999]] [[999]]"
        XCTAssertTrue(value != request.maskedValue(forField: fieldId), "Value was not succesfully masked.")

        XCTAssertTrue(request.maskedValue(forField: "999") == nil, "Value was found: \(request.maskedValue(forField: "999")!).")

    }

    func testIsPartOfAccount() {
        guard let field = request.fieldValues.first?.key else {
            XCTFail("There was no field.")
            return
        }

        let isPartOf = request.isPartOfAccountOnFile(field: field)
        XCTAssertTrue(isPartOf, "Was not part of file.")

        XCTAssertTrue(!request.isPartOfAccountOnFile(field: "NotPartOf"), "There is not suppose to be a file.")
    }

    func testIsReadOnly() {
        guard let field = request.fieldValues.first?.key else {
            XCTFail("There was no field.")
            return
        }

        XCTAssertTrue(!request.isReadOnly(field: field), "It is NOT suppose to be read only.")

        account.attributes.attributes.first?.status = .readOnly
        XCTAssertTrue(request.isReadOnly(field: field), "It is suppose to be read only.")

        XCTAssertTrue(!request.isReadOnly(field: "9999"), "It is NOT suppose to be read only.")
    }

    func testUnmaskedValues() {
        print("Masked: \(String(describing: request.maskedValue(forField: fieldId)))")
        XCTAssertTrue(request.unmaskedFieldValues?.first != nil, "No unmasked items.")
        XCTAssertTrue(request.unmaskedFieldValues?.first!.value == "1", "No unmasked items.")
    }

    func testUnmaskedValue() {
        print("Masked: \(String(describing: request.maskedValue(forField: fieldId)))")
        XCTAssertTrue(request.unmaskedValue(forField: fieldId) == "1", "No unmasked items.")

        request.paymentProduct?.paymentProductField(withId: fieldId)?.displayHints.mask = "12345"
        print("Masked: \(String(describing: request.maskedValue(forField: fieldId)))")
        XCTAssertTrue(request.unmaskedValue(forField: fieldId) == "", "No unmasked items.")

        XCTAssertTrue(request.unmaskedValue(forField: "9999") == nil, "Unexpected success.")
    }

    // session.prepare attempts to store the key that is returned in the keystore, which seems to no longer be possible in tests.
    // Investigation into how we can fix this test is required.
    func ignore_testPrepare() {
        let host = "ams1.sandbox.api-ingenico.com"
        stub(condition: isHost("\(host)") && isPath("/client/v1/customer-id/crypto/publickey") && isMethodGET()) { _ in
            let response = [
                    "keyId": "86b64e4e-f43e-4a27-9863-9bbd5b499f82",
                    "publicKey": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkiJlGL1QjUnGDLpMNBtZPYVtOU121jfFcV4WrZayfw9Ib/1AtPBHP/0ZPocdA23zDh6aB+QiOQEkHZlfnelBNnEzEu4ibda3nDdjSrKveSiQPyB5X+u/IS3CR48B/g4QJ+mcMV9hoFt6Hx3R99A0HWMs4um8elQsgB11MsLmGb1SuLo0S1pgL3EcckXfBDNMUBMQ9EtLC9zQW6Y0kx6GFXHgyjNb4yixXfjo194jfhei80sVQ49Y/SHBt/igATGN1l18IBDtO0eWmWeBckwbNkpkPLAvJfsfa3JpaxbXwg3rTvVXLrIRhvMYqTsQmrBIJDl7F6igPD98Y1FydbKe5QIDAQAB"
                ]
            return OHHTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        let expectation = self.expectation(description: "Response provided")

        session.prepare(request, success: { (request) in
            expectation.fulfill()
        }) { (error) in
            XCTFail("Prepare failed: \(error).")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }

}
