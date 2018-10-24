//
//  AssetManager.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

// Enable subscripting userdefaults
extension UserDefaults {
    subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
}

public class AssetManager {
    public let logoFormat = "pp_logo_%@"
    public let tooltipFormat = "pp_%@_tooltip_%@"
    
    public var documentsFolderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    public var fileManager = FileManager() // var for testing
    public var sdkBundle = Bundle(path: SDKConstants.kSDKBundlePath ?? "") { // var for testing
        didSet {
            initImageMapping()
        }
    }
    public var imageMapping: [AnyHashable : Any]?
    
    public init() {
        initImageMapping()
    }
    
    /*
     An initial mapping from image identifiers to paths is stored in the bundle.
     This mapping is transferred to the device and kept up to date.
     */
    public func initImageMapping() {
        guard let sdk = sdkBundle, let imageMappingPath = sdk.path(forResource: "imageMapping", ofType: "plist"),
            let mapping = fileManager.dict(atPath: imageMappingPath) as? [AnyHashable : Any] else {
            return
        }
        imageMapping = mapping
        
        UserDefaults.standard[SDKConstants.kImageMapping] = imageMapping
        UserDefaults.standard[SDKConstants.kImageMappingInitialized] = true
        UserDefaults.standard.synchronize()
    }
    
    public func logoIdentifier(with paymentItem: BasicPaymentItem) -> String {
        guard let url = URL(string: paymentItem.displayHints.logoPath) else {
            Macros.DLog(message: "Logo path not found.")
            return "Logo path not found."
        }
        var fileName = url.lastPathComponent
        fileName = fileName.replacingOccurrences(of: ".png", with: "")
        
        if let range = fileName.range(of: "_", options: .backwards) {
            fileName = String(fileName[..<range.lowerBound])
        }
        
        return fileName
    }
    
    public func initializeImages(for paymentItems: [BasicPaymentItem]) {
        for paymentItem in paymentItems {
            paymentItem.displayHints.logoImage = logoImage(forItem: paymentItem.identifier)
        }
    }
    
    public func initializeImages(for paymentItem: BasicPaymentItem) {
        paymentItem.displayHints.logoImage = logoImage(forItem: paymentItem.identifier)
        
        if let item = paymentItem as? PaymentItem {
            for field in item.fields.paymentProductFields where field.displayHints.tooltip?.imagePath != nil {
                field.displayHints.tooltip?.image = tooltipImage(forItem: item.identifier, field: field.identifier)
            }
        }
    }
    
    public func updateImagesAsync(for paymentItems: [BasicPaymentItem], baseURL: String) {
        updateImagesAsync(for: paymentItems, baseURL: baseURL, nil)
    }
    
    public func updateImagesAsync(for paymentItem: BasicPaymentItem, baseURL: String) {
        updateImagesAsync(for: paymentItem, baseURL: baseURL, nil)
    }
    
    public func updateImagesAsync(for paymentItems: [BasicPaymentItem], baseURL: String, _ callback: (() -> Void)?) {
        DispatchQueue.global().async {
            self.updateImages(for: paymentItems, baseURL: baseURL)
            
            if let callback = callback {
                DispatchQueue.main.async {
                    callback()
                }
            }
        }
    }
    
    public func updateImagesAsync(for paymentItem: BasicPaymentItem, baseURL: String, _ callback: (() -> Void)?) {
        DispatchQueue.global().async {
            self.updateImages(for: paymentItem, baseURL: baseURL)
            
            if let callback = callback {
                DispatchQueue.main.async {
                    callback()
                }
            }
        }
    }
    
    public func updateImages(for paymentItems: [BasicPaymentItem], baseURL: String) {
        for object in paymentItems {
            let paymentItem = object
            let logoPath = paymentItem.displayHints.logoPath
            let identifier = String(format: self.logoFormat, paymentItem.identifier)
            updateImage(withIdentifier: identifier, newPath: logoPath, baseURL: baseURL)
        }
        
        UserDefaults.standard[SDKConstants.kImageMapping] = imageMapping
        UserDefaults.standard.synchronize()
    }
    
    public func updateImages(for paymentItem: BasicPaymentItem, baseURL: String) {
        if let item = paymentItem as? PaymentItem {
            let fields = item.fields
            
            for field in fields.paymentProductFields where field.displayHints.tooltip?.imagePath != nil {
                let identifier = String(format: self.tooltipFormat, paymentItem.identifier, field.identifier)
                self.updateImage(withIdentifier: identifier, newPath: field.displayHints.tooltip!.imagePath!, baseURL: baseURL)
            }
        }
        
        
        UserDefaults.standard[SDKConstants.kImageMapping] = imageMapping
        UserDefaults.standard.synchronize()
    }
    
    public func updateImage(withIdentifier identifier: String, newPath: String, baseURL: String) {
        var currentPath = ""
        
        if let img = imageMapping, let path = img[identifier] as? String {
            currentPath = path
        }
        
        if currentPath == newPath {
            return
        }
        /*
         A new image for this identifier is available. Update the mapping
         from image identifiers to paths on the device, and store the new
         image in the documents folder.
         */
        let newURL = URL(string: "\(baseURL)/\(newPath)")!
        let imagePath = URL(fileURLWithPath: "\(documentsFolderPath)/\(identifier)")
        
        do {
            let data = try fileManager.data(atURL: newURL)
            try fileManager.write(toURL: imagePath, data: data, options: [])
            if imageMapping != nil {
                imageMapping![identifier] = newPath
            }
        } catch {
            Macros.DLog(message: "Unable to save image: \(identifier)")
        }
    }
    
    public func logoImage(forItem paymentItemId: String) -> UIImage {
        let identifier = String(format: logoFormat, paymentItemId)
        return image(forIdentifier: identifier)
    }
    
    public func tooltipImage(forItem paymentItemId: String, field paymentProductFieldId: String) -> UIImage {
        let identifier = String(format: self.tooltipFormat, paymentItemId, paymentProductFieldId)
        return image(forIdentifier: identifier)
    }
    
    public func image(forIdentifier identifier: String) -> UIImage {
        /*
         If an image for this identifier is available in the documents folder,
         this image is newer than the one in the bundle and should be used.
         */
        let imagePath = "\(documentsFolderPath)/\(identifier)"
        
        if let image = fileManager.image(atPath: imagePath) {
            return image
        }
        
        /*
         If there's no updated image available in the documents folder,
         use the one in the bundle.
         */
        if let sdk = sdkBundle, let imagePath = sdk.path(forResource: identifier , ofType: "png"),
            let image = fileManager.image(atPath: imagePath) {
            return image
        }
        
        // Could not find image so return an empty image
        return UIImage()
    }
}
