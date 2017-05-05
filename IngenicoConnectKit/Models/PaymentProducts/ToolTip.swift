//
//  ToolTip.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

public class ToolTip: ResponseObjectSerializable {
    
    public var imagePath: String?
    public var image: UIImage?
    
    required public init(json: [String : Any]) {
        imagePath = json["image"] as? String
    }
}
