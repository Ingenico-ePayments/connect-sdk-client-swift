//
//  PaymentItemDisplayHints.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

public class PaymentItemDisplayHints {

    public var displayOrder: Int?
    public var label: String?
    public var logoPath: String
    public var logoImage: UIImage?

    required public init?(json: [String: Any]) {
        if let input = json["label"] as? String {
            label = input
        }
        guard let logoPath = json["logo"] as? String else {
            return nil
        }
        self.logoPath = logoPath

        displayOrder = json["displayOrder"] as? Int
    }

}
