//
//  FileManager.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import UIKit

public class FileManager {
    public func dict(atPath path: String) -> NSDictionary? {
        return NSDictionary(contentsOfFile: path)
    }
    
    public func image(atPath path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }
    
    public func data(atURL url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }
    
    public func write(toURL url: URL, data: Data, options: Data.WritingOptions) throws {
        try data.write(to: url, options: options)
    }
}
