//
//  ConnectSDKTestCase.swift
//  IngenicoConnectKitTests
//
//  Created for Ingenico ePayments on 28/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import IngenicoConnectKit

class ConnectSDKTestCase: XCTestCase {
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

    func testInitialize() {
        ConnectSDK.close()

        ConnectSDK.initialize(connectSDKConfiguration: sdkConfiguration, paymentConfiguration: paymentConfiguration)

        XCTAssertNotNil(ConnectSDK.clientApi, "clientApi is nil")
        XCTAssertNotNil(ConnectSDK.connectSDKConfiguration, "connectSDKConfiguration is nil")
    }

    func testClose() {
        ConnectSDK.initialize(connectSDKConfiguration: sdkConfiguration, paymentConfiguration: paymentConfiguration)

        XCTAssertNotNil(ConnectSDK.clientApi, "clientApi is nil")
        XCTAssertNotNil(ConnectSDK.connectSDKConfiguration, "connectSDKConfiguration is nil")

        ConnectSDK.close()
    }

    func testEncryptPaymentRequest() {
        ConnectSDK.initialize(connectSDKConfiguration: sdkConfiguration, paymentConfiguration: paymentConfiguration)

        stub(condition: isHost(host)) { _ in
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
        let dummyPaymentRequest = PaymentRequest(paymentProduct: paymentProduct)

        ConnectSDK.encryptPaymentRequest(
            dummyPaymentRequest,
            success: { _ in
                expectation.fulfill()
            },
            failure: { error in
                XCTFail("Unexpected failure during testEncryptPaymentRequest: \(error.localizedDescription)")
                expectation.fulfill()
            },
            apiFailure: { errorResponse in
                XCTFail("Unexpected api failure during testEncryptPaymentRequest: \(errorResponse.errors[0].message)")
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
