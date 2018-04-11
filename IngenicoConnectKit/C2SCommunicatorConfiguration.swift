//
//  C2SCommunicatorConfiguration.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

public class C2SCommunicatorConfiguration {
    let clientSessionId: String
    let customerId: String
    let region: Region
    let environment: Environment
    let util: Util
    let appIdentifier: String
    let ipAddress: String?
    
    @available(*, deprecated, message: "use method init(clientSessionId:baseURL:assetBaseURL:environment:appIdentifier:ipAddress:util:) instead")
    public init(clientSessionId: String, customerId: String, region: Region, environment: Environment, appIdentifier: String, util: Util = Util.shared) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.region = region
        self.environment = environment
        self.util = util
        self.appIdentifier = appIdentifier
        self.ipAddress = nil
    }
    
    @available(*, deprecated, message: "use method init(clientSessionId:baseURL:assetBaseURL:environment:appIdentifier:ipAddress:util:) instead")
    public init(clientSessionId: String, customerId: String, region: Region, environment: Environment, appIdentifier: String, ipAddress: String?, util: Util = Util.shared) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.region = region
        self.environment = environment
        self.util = util
        self.appIdentifier = appIdentifier
        self.ipAddress = ipAddress
    }
    public init(clientSessionId: String, customerId: String, baseURL: String, assetBaseURL: String, appIdentifier: String, util: Util = Util.shared) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.util = util
        self.appIdentifier = appIdentifier
        self.ipAddress = nil
        self.environment = Environment.production
        self.region = Region.AMS
        
        self.baseURL = baseURL
        self.assetsBaseURL = assetBaseURL
    }
    public init(clientSessionId: String, customerId: String, baseURL: String, assetBaseURL: String, appIdentifier: String, ipAddress: String?, util: Util = Util.shared) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.util = util
        self.appIdentifier = appIdentifier
        self.ipAddress = ipAddress
        self.environment = Environment.production
        self.region = Region.AMS

        self.baseURL = baseURL
        self.assetsBaseURL = assetBaseURL
    }
    public var _baseURL: String?
    
    /// New base URL should be a valid URL
    public var baseURL: String {
        get {
            return _baseURL ?? util.C2SBaseURL(by: region, environment: environment)
        }
        set {
            _baseURL = fixURL(url: newValue)
        }
    }
    private func fixURL(url: String) -> String? {
        // Assume valid URL
        if var finalComponents = URLComponents(string: url) {
            var components = finalComponents.path.split(separator: "/").map { String($0)}
            let versionComponents = (SDKConstants.kApiVersion as NSString).pathComponents
            let error = {
                fatalError("This version of the connectSDK is only compatible with \(versionComponents.joined(separator: "/")) , you supplied: '\(components.joined(separator: "/"))'")
            }
            
            switch components.count {
            case 0:
                components = versionComponents
            case 1:
                if components[0] != versionComponents[0] {
                    error()
                }
                components[0] = components[0]
                components.append(versionComponents[1])
            case 2:
                if components[0] != versionComponents[0] {
                    error()
                }
                if components[1] != versionComponents[1] {
                    error()
                }
            default:
                error()
                
            }
            finalComponents.path = "/" + components.joined(separator: "/")
            return finalComponents.url?.absoluteString
        }
        return nil
    }
    private var _assetsBaseURL: String?
    public var assetsBaseURL: String {
        get {
            return _assetsBaseURL ?? util.assetsBaseURL(by: region, environment: environment)
        }
        set {
            _assetsBaseURL = newValue
        }
    }
    
    public var base64EncodedClientMetaInfo: String? {
        return util.base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: ipAddress)
    }
}
