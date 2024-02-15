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

    var request: PaymentRequest!
    var account: AccountOnFile!
    let fieldId = "1"
    var attribute: AccountOnFileAttribute!
    let session = Session(
        clientSessionId: "client-session-id",
        customerId: "customer-id",
        baseURL: "https://ams1.sandbox.api-ingenico.com/client/v1",
        assetBaseURL: "https://ams1.sandbox.api-ingenico.com/client/v1/assets",
        appIdentifier: "",
        loggingEnabled: false
    )

    override func setUp() {
        super.setUp()

        let paymentProductJSON = Data("""
        {
            "fields": [],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": {
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/templates/master/global/css/img/ppimages/pp_logo_1_v1.png"
            },
            "usesRedirectionTo3rdParty": false
        }
        """.utf8)

        guard let paymentProduct = try? JSONDecoder().decode(PaymentProduct.self, from: paymentProductJSON) else {
            XCTFail("Not a valid PaymentProduct")
            return
        }

        request = PaymentRequest(paymentProduct: paymentProduct)

        let accountJSON = Data("""
        {
            "id": 1,
            "paymentProductId": 1,
            "attributes": [{
                "key": "\(fieldId)",
                "value": "1111222233334444",
                "status": "CAN_WRITE"
            }]
        }
        """.utf8)
        account = try? JSONDecoder().decode(AccountOnFile.self, from: accountJSON)
        guard let account else {
            XCTFail("Not a valid AccountOnFile")
            return
        }

        attribute = account.attributes.attributes.first

        request.accountOnFile = account

        let fieldDictionary = [
            "displayHints": [
                "displayOrder": 0,
                "formElement": [
                    "type": "text"
                ]
            ],
            "id": fieldId,
            "type": "numericstring"
        ] as [String: Any]

        guard let fieldJSON = try? JSONSerialization.data(withJSONObject: fieldDictionary) else {
            XCTFail("Not a valid Dictionary")
            return
        }
        guard let field = try? JSONDecoder().decode(PaymentProductField.self, from: fieldJSON) else {
            XCTFail("Not a valid PaymentProductField")
            return
        }

        request.paymentProduct?.fields.paymentProductFields.append(field)
        request.paymentProduct?.paymentProductField(withId: fieldId)?.displayHints.mask =
            "{{9999}} {{9999}} {{9999}} {{9999}} {{9999}}"
        request.setValue(forField: field.identifier, value: "1111222233334444")
        request.formatter = StringFormatter()

        request.validate()
    }

    func testGetValue() {
        let value = request.getValue(forField: attribute.key)
        XCTAssertTrue(value != nil, "Did not find value of existing attribute.")

        XCTAssertTrue(
            request.getValue(forField: "9999") == nil,
            "Should have been nil: \(request.getValue(forField: "9999")!)."
        )

        XCTAssertTrue(request.getValue(forField: fieldId) == "1111222233334444", "Value not found.")
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

    func testMaskedFieldValues() {
        XCTAssertEqual(request.maskedFieldValues?.first?.value, "1111 2222 3333 4444 ")
    }

    func testMaskedValue() {
        let value = request.getValue(forField: attribute.key)
        XCTAssertTrue(value != nil, "Value was not set.")

        XCTAssertEqual(request.maskedValue(forField: fieldId), "1111 2222 3333 4444 ")
    }

    func testUnmaskedFieldValues() {
        XCTAssertEqual(request.unmaskedFieldValues?.first?.value, "1111222233334444")
    }

    func testUnmaskedValue() {
        XCTAssertEqual(request.unmaskedValue(forField: fieldId), "1111222233334444")
    }

    func testPrepare() {
        let host = "ams1.sandbox.api-ingenico.com"
        stub(condition: isHost("\(host)") && isPath("/client/v1/customer-id/crypto/publickey") && isMethodGET()) { _ in
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

        session.prepare(request, success: { (_) in
            expectation.fulfill()
        }, failure: { (error) in
            XCTFail("Prepare failed: \(error).")
            expectation.fulfill()
        })

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                print("Timeout error: \(error.localizedDescription)")
            }
        }
    }
}
