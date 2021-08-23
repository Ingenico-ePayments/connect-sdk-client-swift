//
//  Util.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import UIKit

public class Util {
    static let shared = Util()
    public var metaInfo: [String: String]? = nil
    
    public var platformIdentifier: String {
        let OSName = UIDevice.current.systemName
        let OSVersion = UIDevice.current.systemVersion
        
        return "\(OSName)/\(OSVersion)"
    }
    
    public var screenSize: String {
        let screenBounds = UIScreen.main.bounds
        let screenScale = UIScreen.main.scale
        let screenSize = CGSize(width: CGFloat(screenBounds.size.width * screenScale), height: CGFloat(screenBounds.size.height * screenScale))
        
        return "\(Int(screenSize.width))\(Int(screenSize.height))"
    }
    
    public var deviceType: String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    public init() {
        metaInfo = [
            "platformIdentifier": platformIdentifier,
            "sdkIdentifier": "SwiftClientSDK/v5.0.1",
            "sdkCreator": "Ingenico",
            "screenSize": screenSize,
            "deviceBrand": "Apple",
            "deviceType": deviceType
        ]
    }
    
    public var base64EncodedClientMetaInfo: String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: nil)
    }
    
    public func base64EncodedClientMetaInfo(withAddedData addedData: [String: String]) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: nil, ipAddress: nil, addedData: addedData)
    }
    
    public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: nil, addedData: nil)
    }
    
    public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?) -> String? {
        return base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: ipAddress, addedData: nil)
    }
    
    public func base64EncodedClientMetaInfo(withAppIdentifier appIdentifier: String?, ipAddress: String?, addedData: [String: String]?) -> String? {
        if let addedData = addedData {
            for (k, v) in addedData {
                metaInfo!.updateValue(v, forKey: k)
            }
        }
        
        if let appIdentifier = appIdentifier, !appIdentifier.isEmpty {
            metaInfo!["appIdentifier"] = appIdentifier
        } else {
            metaInfo!["appIdentifier"] = "UNKNOWN"
        }
        
        if let ipAddress = ipAddress, !ipAddress.isEmpty {
            metaInfo!["ipAddress"] = ipAddress
        }
        
        return base64EncodedString(fromDictionary: metaInfo!)
    }

    @available(*, deprecated, message: "Use the clientApiUrl and assetUrl returned in the server to server Create Client Session API to obtain the endpoints for the Client API.")
    public func C2SBaseURL(by region: Region, environment: Environment) -> String {
        switch region {
        case .EU:
            switch environment {
            case .production:
                return "https://ams1.api-ingenico.com/client/v1"
            case .preProduction:
                return "https://ams1.preprod.api-ingenico.com/client/v1"
            case .sandbox:
                return "https://ams1.sandbox.api-ingenico.com/client/v1"
            }
            
        case .US:
            switch environment {
            case .production:
                return "https://us.api-ingenico.com/client/v1"
            case .preProduction:
                return "https://us.preprod.api-ingenico.com/client/v1"
            case .sandbox:
                return "https://us.sandbox.api-ingenico.com/client/v1"
            }
            
        case .AMS:
            switch environment {
            case .production:
                return "https://ams2.api-ingenico.com/client/v1"
            case .preProduction:
                return "https://ams2.preprod.api-ingenico.com/client/v1"
            case .sandbox:
                return "https://ams2.sandbox.api-ingenico.com/client/v1"
            }
            
        case .PAR:
            switch environment {
            case .production:
                return "https://par.api-ingenico.com/client/v1"
            case .preProduction:
                return "https://par-preprod.api-ingenico.com/client/v1"
            case .sandbox:
                return "https://par.sandbox.api-ingenico.com/client/v1"
            }
        }
        
    }

    @available(*, deprecated, message: "Use the clientApiUrl and assetUrl returned in the server to server Create Client Session API to obtain the endpoints for the Client API.")
    public func assetsBaseURL(by region: Region, environment: Environment) -> String {
        switch region {
        case .EU:
            switch environment {
            case .production:
                return "https://assets.pay1.secured-by-ingenico.com"
            case .preProduction:
                return "https://assets.pay1.preprod.secured-by-ingenico.com"
            case .sandbox:
                return "https://assets.pay1.sandbox.secured-by-ingenico.com"
            }
            
        case .US:
            switch environment {
            case .production:
                return "https://assets.pay2.secured-by-ingenico.com"
            case .preProduction:
                return "https://assets.pay2.preprod.secured-by-ingenico.com"
            case .sandbox:
                return "https://assets.pay2.sandbox.secured-by-ingenico.com"
            }
            
        case .AMS:
            switch environment {
            case .production:
                return "https://assets.pay3.secured-by-ingenico.com"
            case .preProduction:
                return "https://assets.pay3.preprod.secured-by-ingenico.com"
            case .sandbox:
                return "https://assets.pay3.sandbox.secured-by-ingenico.com"
            }
            
        case .PAR:
            switch environment {
            case .production:
                return "https://assets.pay4.secured-by-ingenico.com"
            case .preProduction:
                return "https://assets.pay4.preprod.secured-by-ingenico.com"
            case .sandbox:
                return "https://assets.pay4.sandbox.secured-by-ingenico.com"
            }
        }
        
    }
    
    //TODO: move to Base64 class
    public func base64EncodedString(fromDictionary dictionary: [AnyHashable: Any]) -> String? {
        guard let json = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            Macros.DLog(message: "Unable to serialize dictionary")
            return nil
        }

        return json.encode()
    }
}
