//
//  C2SCommunicatorConfiguration.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

@available(
    *,
    deprecated,
    message:
        """
        In a future release, this class, its functions and its properties will become internal to the SDK.
        """
)
public class C2SCommunicatorConfiguration {
    let clientSessionId: String
    let customerId: String
    let util: Util
    let appIdentifier: String
    let ipAddress: String?
    internal var loggingEnabled: Bool

    @available(
        *,
        deprecated,
        message: """
                 Use the clientApiUrl and assetUrl returned in the server to server Create Client Session API
                 to obtain the endpoints for the Client API.
                 """
    )
    let region: Region
    @available(
        *,
        deprecated,
        message: """
                 Use the clientApiUrl and assetUrl returned in the server to server Create Client Session API
                 to obtain the endpoints for the Client API.
                 """
    )
    let environment: Environment

    @available(
        *,
        deprecated,
        message: """
                 Use method init(
                    clientSessionId:
                    customerId:
                    baseURL:
                    assetBaseURL:
                    appIdentifier:
                    util:
                    loggingEnabled:
                 ) instead
                 """
    )
    public init(
        clientSessionId: String,
        customerId: String,
        region: Region,
        environment: Environment,
        appIdentifier: String,
        util: Util? = nil,
        loggingEnabled: Bool = false
    ) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.region = region
        self.environment = environment
        self.util = util ?? Util.shared
        self.appIdentifier = appIdentifier
        self.ipAddress = nil
        self.loggingEnabled = loggingEnabled
    }

    @available(
        *,
        deprecated,
        message: """
                 Use method init(
                    clientSessionId:
                    customerId:
                    baseURL:
                    assetBaseURL:
                    appIdentifier:
                    ipAddress:
                    util:
                    loggingEnabled:
                 ) instead
                 """
    )
    public init(
        clientSessionId: String,
        customerId: String,
        region: Region,
        environment: Environment,
        appIdentifier: String,
        ipAddress: String?,
        util: Util? = nil,
        loggingEnabled: Bool = false
    ) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.region = region
        self.environment = environment
        self.util = util ?? Util.shared
        self.appIdentifier = appIdentifier
        self.ipAddress = ipAddress
        self.loggingEnabled = loggingEnabled
    }

    public init(
        clientSessionId: String,
        customerId: String,
        baseURL: String,
        assetBaseURL: String,
        appIdentifier: String,
        util: Util? = nil,
        loggingEnabled: Bool = false
    ) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.util = util ?? Util.shared
        self.appIdentifier = appIdentifier
        self.ipAddress = nil
        self.environment = Environment.production
        self.region = Region.AMS
        self.loggingEnabled = loggingEnabled

        self.baseURL = baseURL
        self.assetsBaseURL = assetBaseURL
    }

    public init(
        clientSessionId: String,
        customerId: String,
        baseURL: String,
        assetBaseURL: String,
        appIdentifier: String,
        ipAddress: String?,
        util: Util? = nil,
        loggingEnabled: Bool = false
    ) {
        self.clientSessionId = clientSessionId
        self.customerId = customerId
        self.util = util ?? Util.shared
        self.appIdentifier = appIdentifier
        self.ipAddress = ipAddress
        self.environment = Environment.production
        self.region = Region.AMS
        self.loggingEnabled = loggingEnabled

        self.baseURL = baseURL
        self.assetsBaseURL = assetBaseURL
    }

    @available(
        *,
        deprecated,
        message:
            """
            In a future release, this property will become private to this class. Use baseURL instead.
            """
    )
    // swiftlint:disable identifier_name
    public var _baseURL: String?
    // swiftlint:enable identifier_name

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
                fatalError(
                    """
                    This version of the connectSDK is only compatible with \(versionComponents.joined(separator: "/")),
                    you supplied: '\(components.joined(separator: "/"))'
                    """
                )
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
