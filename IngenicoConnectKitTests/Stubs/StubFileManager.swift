//
//  StubFileManager.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import UIKit
@testable import IngenicoConnectKit

class StubFileManager: IngenicoConnectKit.FileManager {
    override func dict(atPath path: String) -> NSDictionary? {
        switch path {
        case "imageMappingFile":
            return [
                "key": "value"
            ]

        default:
            return nil
        }
    }

    override func image(atPath path: String) -> UIImage? {
        let image = UIImage()

        switch path {
        case _ where path.contains("/pp_logo_"):
            image.accessibilityLabel = "logoStubResponse"
            return image

        case _ where path.contains("_tooltip_"):
            let field = path.components(separatedBy: "_").last
            image.accessibilityLabel = "tooltipStubResponse-\(field!)"
            return image

        default:
            return nil
        }
    }

    override func data(atURL url: URL) throws -> Data {
        switch url.absoluteString {
        case "//this/is_a_test.png":
            return Data(base64Encoded: "test")!

        case "//tooltips/are_here.png":
            return Data(base64Encoded: "test")!

        default:
            guard let data = try? Data(contentsOf: url) else {
                fatalError("URL invalid")
            }

            return data

        }
    }

    override func write(toURL url: URL, data: Data, options: Data.WritingOptions) {
        guard url.absoluteString.contains("pp_logo_") ||
              url.absoluteString.contains("_tooltip_") else {
            fatalError("URL invalid")
        }
    }
}
