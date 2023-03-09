//
//  AssetManagerTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class AssetManagerTestCase: XCTestCase {

    let assetManager = AssetManager()
    var paymentItem: PaymentItem!

    override func setUp() {
        super.setUp()

        assetManager.fileManager = StubFileManager()
        assetManager.sdkBundle = StubBundle()

        paymentItem = PaymentProduct(json: [
            "fields": [[:]],
            "id": 1,
            "paymentMethod": "card",
            "displayHints": [
                "displayOrder": 20,
                "label": "Visa",
                "logo": "/this/is_a_test.png"
            ]
        ])!

        paymentItem.fields = PaymentProductFields()
        for index in 0..<5 {
            let field = PaymentProductField(json: [
                "displayHints": [
                    "formElement": [
                        "type": "text"
                    ],
                    "tooltip": [
                        "image": "/tooltips/are_here.png"
                    ]
                ],
                "id": "field\(index)",
                "type": "numericstring"
            ])!

          paymentItem.fields.paymentProductFields.append(field)
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLogoIdentifier() {
        var logoIdentifier = assetManager.logoIdentifier(with: paymentItem)
        XCTAssertEqual(logoIdentifier, "is_a", "Did not properly identify logo identifier with multiple underscores")

        paymentItem.displayHints.logoPath = "/this/is/a_test.png"
        logoIdentifier = assetManager.logoIdentifier(with: paymentItem)
        XCTAssertEqual(logoIdentifier, "a", "Did not properly identify logo identifier with single underscore")

        paymentItem.displayHints.logoPath = "/this/is/a/test.png"
        logoIdentifier = assetManager.logoIdentifier(with: paymentItem)
        XCTAssertEqual(logoIdentifier, "test", "Did not properly identify logo identifier without underscores")

        paymentItem.displayHints.logoPath = "/this/is/a/_.png"
        logoIdentifier = assetManager.logoIdentifier(with: paymentItem)
        XCTAssertEqual(logoIdentifier, "", "Did not properly identify logo identifier for edge case")
    }

    func testInitializeImagesForPaymentItems() {
        XCTAssertNotEqual(paymentItem.displayHints.logoImage?.accessibilityLabel, "logoStubResponse")

        assetManager.initializeImages(for: [paymentItem])

        XCTAssertEqual(paymentItem.displayHints.logoImage?.accessibilityLabel, "logoStubResponse")
    }

    func testInitializeImagesForPaymentItem() {
        XCTAssertNotEqual(paymentItem.displayHints.logoImage?.accessibilityLabel, "logoStubResponse")

        assetManager.initializeImages(for: paymentItem)

        XCTAssertEqual(paymentItem.displayHints.logoImage?.accessibilityLabel, "logoStubResponse")

        for index in 0..<paymentItem.fields.paymentProductFields.count {
          let field = paymentItem.fields.paymentProductFields[index]

          XCTAssertEqual(field.displayHints.tooltip?.image?.accessibilityLabel, "tooltipStubResponse-field\(index)")
        }
    }

    func testUpdateImagesForPaymentItems() {
        if let imageMapping = UserDefaults.standard[SDKConstants.kImageMapping] as? [String: String] {
          let path = imageMapping["pp_logo_identifier"]
          XCTAssertNil(path)
        }

        assetManager.updateImages(for: [paymentItem], baseURL: "")

        if let imageMapping = UserDefaults.standard[SDKConstants.kImageMapping] as? [String: String] {
          XCTAssertEqual(imageMapping["pp_logo_1"], "/this/is_a_test.png")
        }
    }

    func testUpdateImagesForPaymentItem() {
        assetManager.updateImages(for: paymentItem, baseURL: "")

        if let imageMapping = UserDefaults.standard[SDKConstants.kImageMapping] as? [String: String] {
            for index in 0..<paymentItem.fields.paymentProductFields.count {
                XCTAssertEqual(imageMapping["pp_1_tooltip_field\(index)"], "/tooltips/are_here.png")
            }
        }
    }

    func testUpdateImagesAsyncForPaymentItems() {
        let expectation = self.expectation(description: "ImageMapping updated")
        if let imageMapping = UserDefaults.standard[SDKConstants.kImageMapping] as? [String: String] {
            let path = imageMapping["pp_logo_1"]
            XCTAssertNil(path)
        }

        assetManager.updateImagesAsync(for: [paymentItem], baseURL: "") {
            if let imageMapping = UserDefaults.standard[SDKConstants.kImageMapping] as? [String: String] {
                XCTAssertEqual(imageMapping["pp_logo_1"], "/this/is_a_test.png")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
            print("Timeout error: \(String(describing: error?.localizedDescription))")
        }
    }

    func testUpdateImagesAsyncForPaymentItem() {
        let expectation = self.expectation(description: "ImageMapping updated")

        assetManager.updateImagesAsync(for: paymentItem, baseURL: "") {
            if let imageMapping = UserDefaults.standard[SDKConstants.kImageMapping] as? [String: String] {
                for index in 0..<self.paymentItem.fields.paymentProductFields.count {
                    XCTAssertEqual(imageMapping["pp_1_tooltip_field\(index)"], "/tooltips/are_here.png")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
            print("Timeout error: \(String(describing: error?.localizedDescription))")
        }
    }
}
