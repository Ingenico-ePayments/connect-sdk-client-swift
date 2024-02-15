//
//  AccountOnFileDisplayHints.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class AccountOnFileDisplayHints: Codable {

    public var labelTemplate: LabelTemplate = LabelTemplate()
    public var logo: String?

    @available(*, deprecated, message: "In a future release, this initializer will become internal to the SDK.")
    public init() {}

    private enum CodingKeys: String, CodingKey {
        case labelTemplate, logo
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let labelTemplates = try? container.decodeIfPresent([LabelTemplateItem].self, forKey: .labelTemplate) {
            for labelTemplate in labelTemplates {
                self.labelTemplate.labelTemplateItems.append(labelTemplate)
            }
        }

        self.logo = try? container.decodeIfPresent(String.self, forKey: .logo)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(labelTemplate.labelTemplateItems, forKey: .labelTemplate)
        try? container.encode(logo, forKey: .logo)
    }
}
