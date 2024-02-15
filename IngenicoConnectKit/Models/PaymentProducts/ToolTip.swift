//
//  ToolTip.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

public class ToolTip: ResponseObjectSerializable, Codable {

    public var label: String?
    public var imagePath: String?
    public var image: UIImage?

    required public init(json: [String: Any]) {
        imagePath = json["image"] as? String
        if let input = json["label"] as? String {
            label = input
        }
    }

    private enum CodingKeys: String, CodingKey {
        case image, label
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imagePath = try? container.decodeIfPresent(String.self, forKey: .image)
        self.label = try? container.decodeIfPresent(String.self, forKey: .label)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(imagePath, forKey: .image)
        try? container.encodeIfPresent(label, forKey: .label)
    }
}
