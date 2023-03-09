//
//  SDKConstants.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import UIKit

public class SDKConstants {

    public static let kSDKLocalizable = "ICSDKLocalizable"
    public static let kImageMapping = "kImageMapping"
    public static let kImageMappingInitialized = "kImageMappingInitialized"
    public static let kIINMapping = "kIINMapping"

    public static let kAndroidPayIdentifier = "320"
    public static let kApplePayIdentifier = "302"

    public static let kApiVersion = "client/v1"
    public static let kSDKBundleIdentifier = "org.cocoapods.IngenicoConnectKit"
    public static var kSDKBundlePath =
        Bundle(identifier: SDKConstants.kSDKBundleIdentifier)?.path(forResource: "IngenicoConnectKit", ofType: "bundle")

    public static func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: String) -> Bool {
        return UIDevice.current.systemVersion.compare(v, options: String.CompareOptions.numeric) != .orderedAscending
    }

}
