//
//  ClientApi.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 24/11/2023.
//  Copyright © 2023 Global Collect Services. All rights reserved.
//

import UIKit

public class ClientApi {
    private let clientApiCommunicator: ClientApiCommunicator

    internal var iinLookupPending = false

    private let preLoadImages: Bool

    private var groupPaymentProducts: Bool {
        return clientApiCommunicator.groupPaymentProducts
    }

    internal var base64EncodedClientMetaInfo: String {
        return clientApiCommunicator.base64EncodedClientMetaInfo
    }

    private var assetUrl: String {
        return clientApiCommunicator.assetUrl
    }

    public init(sdkConfiguration: ConnectSDKConfiguration, paymentConfiguration: PaymentConfiguration) {
        self.preLoadImages = sdkConfiguration.preLoadImages
        self.clientApiCommunicator =
            ClientApiCommunicator(sdkConfiguration: sdkConfiguration, paymentConfiguration: paymentConfiguration)
    }

    public func paymentProducts(
        success: @escaping (_ paymentProducts: BasicPaymentProducts) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.paymentProducts(
            success: { paymentProducts in
                if self.preLoadImages {
                    self.setLogoForPaymentItems(for: paymentProducts.paymentProducts) {
                        success(paymentProducts)
                    }
                } else {
                    success(paymentProducts)
                }
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    public func paymentProductNetworks(
        forProduct paymentProductId: String,
        success: @escaping (_ paymentProductNetworks: PaymentProductNetworks) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.paymentProductNetworks(
            forProduct: paymentProductId,
            success: success,
            failure: failure,
            apiFailure: apiFailure
        )
    }

    public func paymentProductGroups(
        success: @escaping (_ paymentProductGroups: BasicPaymentProductGroups) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.paymentProductGroups(
            success: { paymentProductGroups in
                if self.preLoadImages {
                    self.setLogoForPaymentProductGroups(for: paymentProductGroups.paymentProductGroups) {
                        success(paymentProductGroups)
                    }
                } else {
                    success(paymentProductGroups)
                }
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    public func paymentItems(
        success: @escaping (_ paymentItems: PaymentItems) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.paymentProducts(
            success: { paymentProducts in
                if self.preLoadImages {
                    self.setLogoForPaymentItems(for: paymentProducts.paymentProducts) {
                        if self.groupPaymentProducts {
                            self.clientApiCommunicator.paymentProductGroups(
                                success: { paymentProductGroups in
                                    self.setLogoForPaymentProductGroups(
                                        for: paymentProductGroups.paymentProductGroups
                                    ) {
                                        let items =
                                            PaymentItems(products: paymentProducts, groups: paymentProductGroups)
                                        success(items)
                                    }

                                },
                                failure: failure,
                                apiFailure: apiFailure
                            )
                        } else {
                            let items = PaymentItems(products: paymentProducts, groups: nil)
                            success(items)
                        }

                    }
                } else {
                    let items = PaymentItems(products: paymentProducts, groups: nil)
                    success(items)
                }
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    public func paymentProduct(
        withId paymentProductId: String,
        success: @escaping (_ paymentProduct: PaymentProduct) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.paymentProduct(
            withId: paymentProductId,
            success: { paymentProduct in
                if self.preLoadImages {
                    self.setTooltipImages(for: paymentProduct)
                    self.setLogoForDisplayHints(for: paymentProduct.displayHints) {
                        success(paymentProduct)
                    }
                } else {
                    success(paymentProduct)
                }
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    public func paymentProductGroup(
        withId paymentProductGroupId: String,
        success: @escaping (_ paymentProductGroup: PaymentProductGroup) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.paymentProductGroup(
            withId: paymentProductGroupId,
            success: { paymentProductGroup in
                if self.preLoadImages {
                    self.setLogoForDisplayHints(for: paymentProductGroup.displayHints) {
                        success(paymentProductGroup)
                    }
                } else {
                    success(paymentProductGroup)
                }
            },
            failure: failure,
            apiFailure: apiFailure
        )
    }

    public func iinDetails(
        forPartialCreditCardNumber partialCreditCardNumber: String,
        success: @escaping (_ iinDetailsResponse: IINDetailsResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        if partialCreditCardNumber.count < 6 {
            let response = IINDetailsResponse(status: .notEnoughDigits)
            success(response)
        } else if self.iinLookupPending == true {
            let response = IINDetailsResponse(status: .pending)
            success(response)
        } else {
            self.iinLookupPending = true
            clientApiCommunicator.iinDetails(
                forPartialCreditCardNumber: partialCreditCardNumber,
                success: { response in
                    self.iinLookupPending = false
                    success(response)
                },
                failure: { error in
                    self.iinLookupPending = false
                    failure(error)
                },
                apiFailure: { errorResponse in
                    self.iinLookupPending = false
                    apiFailure(errorResponse)
                }
            )
        }
    }

    // swiftlint:disable function_parameter_count
    public func convert(
        amountInCents: Int,
        sourceCurrency: String,
        targetCurrency: String,
        success: @escaping (_ convertedAmountResponse: ConvertedAmountResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.convert(
            amountInCents: amountInCents,
            sourceCurrency: sourceCurrency,
            targetCurrency: targetCurrency,
            success: success,
            failure: failure,
            apiFailure: apiFailure
        )
    }
    // swiftlint:enable function_parameter_count

    public func directory(
        forProduct paymentProductId: String,
        success: @escaping (_ directory: DirectoryEntries) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.directory(
            forProduct: paymentProductId,
            success: success,
            failure: failure,
            apiFailure: apiFailure
        )
    }

    public func thirdPartyStatus(
        forPayment paymentId: String,
        success: @escaping (_ thirdPartyStatusResponse: ThirdPartyStatusResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.thirdPartyStatus(
            forPayment: paymentId,
            success: success,
            failure: failure,
            apiFailure: apiFailure
        )
    }

    public func publicKey(
        success: @escaping (_ publicKeyResponse: PublicKeyResponse) -> Void,
        failure: @escaping (_ error: Error) -> Void,
        apiFailure: @escaping (_ errorResponse: ApiErrorResponse) -> Void
    ) {
        clientApiCommunicator.publicKey(
            success: success,
            failure: failure,
            apiFailure: apiFailure
        )
    }

    private func setLogoForPaymentItems(for paymentItems: [BasicPaymentItem], completion: @escaping() -> Void) {
        var counter = 0
        for paymentItem in paymentItems {
            setLogoForDisplayHints(for: paymentItem.displayHints, completion: {
                counter += 1
                if counter == paymentItems.count {
                    completion()
                }
            })
        }
    }

    private func setLogoForPaymentProductGroups(
        for paymentProductGroups: [BasicPaymentProductGroup],
        completion: @escaping() -> Void
    ) {
        var counter = 0
        for paymentProductGroup in paymentProductGroups {
            setLogoForDisplayHints(for: paymentProductGroup.displayHints, completion: {
                counter += 1
                if counter == paymentProductGroups.count {
                    completion()
                }
            })
        }
    }

    private func setLogoForDisplayHints(for displayHints: PaymentItemDisplayHints, completion: @escaping() -> Void) {
        self.getLogoByStringURL(from: displayHints.logoPath) { data, _, error in
            if let imageData = data, error == nil {
                displayHints.logoImage = UIImage(data: imageData)
            }
            completion()
        }
    }

    private func setTooltipImages(for paymentItem: PaymentItem) {
        for field in paymentItem.fields.paymentProductFields {
            guard let tooltip = field.displayHints.tooltip,
                  let imagePath = tooltip.imagePath else { return }

            self.getLogoByStringURL(from: imagePath) { data, _, error in
                if let imageData = data, error == nil {
                    tooltip.image = UIImage(data: imageData)
                }
            }
        }
    }

    internal func getLogoByStringURL(
        from url: String,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        let completeUrl = assetUrl + url

        guard let encodedUrlString = completeUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            Macros.DLog(message: "Unable to decode URL for url string: \(url)")
            completion(nil, nil, nil)
            return
        }

        guard let encodedUrl = URL(string: encodedUrlString) else {
            Macros.DLog(message: "Unable to create URL for url string: \(encodedUrlString)")
            completion(nil, nil, nil)
            return
        }

        URLSession.shared.dataTask(with: encodedUrl, completionHandler: {data, response, error in
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        }).resume()
    }
}
