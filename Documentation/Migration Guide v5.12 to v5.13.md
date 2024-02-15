# Migrating from version 5.12 to version 5.13
This migration guide will help you migrate from version 5.12 to version 5.13.

For version 5.13, the SDK was updated with a new architecture where initialization and error handling of the SDK have been improved. These changes are *not* mandatory to move to version 5.13 of the SDK. The old architecture has been deprecated, but is still available and will not be removed until a future major version update.

## Migrating to the new architecture

> *Note:* The changes described in this section are not breaking at this time. The old architecture of the SDK, using an instance of `Session`, has been deprecated, but will be available until the next major version update.

Major improvements have been made to the SDKs error handling, and to the initialization of the SDK. This is an overview of all architecture changes:

- The SDK has a new entry point: `ConnectSDK`. Its initialize method should be used to provide `ConnectSDKConfiguration`, containing `SessionConfiguration`, obtained through the Server to Server API, and `PaymentConfiguration`.
- Session has been replaced by `ClientApi`. Once the SDK has been initialized, an instance of `ClientApi` can be obtained by calling `ConnectSDK.clientApi`.
- Error handling has been improved when making requests through `ClientApi`. When making a call, an additional argument must be provided which will be called to handle an API error when one occurs. This means that every call will always require at least the following parameters:
    - `success: (_ response: ExpectedResponseType) -> Void` - Called when the request was successful. The response parameter will contain the response object, according to the existing, unchanged domain model.
    - `failure: (_ error: Error) -> Void` - Called when an exception occurred while executing the request. The error parameter will contain the `Error` that indicates what went wrong.
    - `apiFailure: (_ errorResponse: ApiErrorResponse) -> Void` - Called when the Connect gateway returned an error response. The errorResponse parameter will contain further information on the error, such as the errorId and a list of `ApiErrorItem`s which contains all returned errors.

### Using the new architecture

The steps below describe how to migrate to the new SDK architecture in version 5.13 of the SDK.

1. Upgrade to the latest Swift Connect SDK version in your `Podfile`:
```
pod 'IngenicoConnectKit', '~> 5.13'
```

Afterwards, run the following command:

```
$ pod install
```

2. Replace `Session` initialization with `ConnectSDK` initialization:
```swift
let sessionConfiguration = SessionConfiguration(
    clientSessionId: "e030f01dda4c4f94891c3cb23b3ccf61",
    customerId: "9008-9a1e01fbbafd4889a77cbb11abb5e688",
    clientApiUrl: "https://ams1.sandbox.api-ingenico.com/client",
    assetUrl: "https://assets.pay1.sandbox.secured-by-ingenico.com/"
)

let connectSDKConfiguration = ConnectSDKConfiguration(
    sessionConfiguration: sessionConfiguration,
    enableNetworkLogs: true, // should be set to false in production
    applicationId: "my-application-id", // optional
    ipAddress: nil, // optional
    preLoadImages: true // true, by default if parameter is not explicitly set
)

let paymentConfiguration = PaymentConfiguration(
    paymentContext: paymentContext,
    groupPaymentProducts: false
)

ConnectSDK.initialize(
    connectSDKConfiguration: connectSDKConfiguration,
    paymentConfiguration: paymentConfiguration
)
```

`ConnectSDKConfiguration` contains properties that allow you to set additional SDK settings:

- `enableNetworkLogs` will log all network requests and responses to the console. This setting can be used to investigate issues. Must be set to false in production targets.
- `applicationId` is the identifier or name that you choose for your app.
- `ipAddress` will be included in the client's meta info when encrypting a `PaymentRequest`.
- `preloadImages` determines whether image resources, initially returned by the API as their location, will be retrieved by the SDK, or whether you will retrieve them on the go when required. The SDK loads the images by default, to make sure behaviour is as it used to be. We have added the option to disable preloading to allow you to use frameworks for image loading on demand.

`PaymentConfiguration` has a property used to determine whether or not to group payment items.

3. Replace all API calls that were previously called via `Session` with `ConnectSDK.clientApi` calls. API calls now require the additional argument `apiFailure`:
```swift
ConnectSDK.clientApi.paymentItems(
    success: { paymentItems in
        // display the contents of paymentItems & accountsOnFile to your customer
    },
    failure: { error in
        // process failure
    },
    apiFailure: { errorResponse in
        // process api failure
    }
)
```

4. Implement error handling for the `failure` and `apiFailure` callbacks.

For more information about version 5.13 or the Swift SDK in general, also review the Swift SDK developer documentation and/or the Swift example apps.

### Deprecations

This is the full list of classes that have become deprecated related to the architecture change. Move away from using these classes, as they will be removed or made unavailable in a future major release.

- `Session`
- `AlamofireWrapper`
- `C2SCommunicator`
- `C2SCommunicatorConfiguration`
- `AssetManager`
- `FileManager`
- `Util`
- `Encryptor`
- `JOSEEncryptor`
- `SessionError`
- `CustomerDetailsError`

## Relevant links
- [Swift Connect SDK on GitHub](https://github.com/Ingenico-ePayments/connect-sdk-client-swift)
- [SwiftUI example app on GitHub](https://github.com/Ingenico-ePayments/connect-sdk-client-swift-example-swiftui)
- [UIKit example app on GitHub](https://github.com/Ingenico-ePayments/connect-sdk-client-swift-example)
- [Swift SDK documentation](https://docs.connect.worldline-solutions.com/documentation/sdk/mobile/swift/)
- [Client API Reference](https://apireference.connect.worldline-solutions.com/c2sapi/v1/en_US/index.html?paymentPlatform=ALL)
