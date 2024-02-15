//
//  StubClientApi.swift
//  IngenicoConnectKitTests
//
//  Created for Ingenico ePayments on 28/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import UIKit
@testable import IngenicoConnectKit

class StubClientApi: IngenicoConnectKit.ClientApi {
    override func getLogoByStringURL(from url: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        // Create an image existing of only a colour
        // This is done just to have an image available
        let image = UIColor.blue.image()

        completion(image.pngData(), nil, nil)
    }
}

extension UIColor {
    func image() -> UIImage {
        let size = CGSize(width: 1, height: 1)

        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
