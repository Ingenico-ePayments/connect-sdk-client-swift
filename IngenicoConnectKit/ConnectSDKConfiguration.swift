//
//  ConnectSDKConfiguration.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 24/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

public class ConnectSDKConfiguration: Decodable {
    public let sessionConfiguration: SessionConfiguration
    public let enableNetworkLogs: Bool
    public let applicationId: String?
    public let ipAddress: String?
    public let preLoadImages: Bool

    public init(
        sessionConfiguration: SessionConfiguration,
        enableNetworkLogs: Bool = false,
        applicationId: String? = nil,
        ipAddress: String? = nil,
        preLoadImages: Bool = true
    ) {
        self.sessionConfiguration = sessionConfiguration
        self.enableNetworkLogs = enableNetworkLogs
        self.applicationId = applicationId
        self.ipAddress = ipAddress
        self.preLoadImages = preLoadImages
    }
}
