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
    
    public convenience init(clientSessionId: String, customerId: String, region: Region, environment: Environment, appIdentifier: String, util: Util = Util.shared) {
        self.init(clientSessionId: clientSessionId, customerId: customerId, region: region, environment: environment, appIdentifier: appIdentifier, ipAddress: nil, util: util)
    }
    
    public init(clientSessionId: String, customerId: String, region: Region, environment: Environment, appIdentifier: String, ipAddress: String?, util: Util = Util.shared) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.region = region
        self.environment = environment
        self.util = util
        self.appIdentifier = appIdentifier
        self.ipAddress = ipAddress
    }
    
    public var baseURL: String {
        return util.C2SBaseURL(by: region, environment: environment)
    }
    
    public var assetsBaseURL: String {
        return util.assetsBaseURL(by: region, environment: environment)
    }
    
    public var base64EncodedClientMetaInfo: String? {
        return util.base64EncodedClientMetaInfo(withAppIdentifier: appIdentifier, ipAddress: ipAddress)
    }
}
