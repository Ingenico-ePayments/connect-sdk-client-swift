//
//  EncryptorTestCase.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import XCTest
@testable import IngenicoConnectKit

class EncryptorTestCase: XCTestCase {
    var encryptor = Encryptor()
    let publicTag = "test-public-tag"
    let privateTag = "tets-private-tag"

    func testGenerateRSAKeyPair() {

        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)
        encryptor.generateRSAKeyPair(withPublicTag: publicTag, privateTag: privateTag)

        let publicKey: SecKey? = encryptor.RSAKey(withTag: publicTag)
        let privateKey: SecKey? = encryptor.RSAKey(withTag: privateTag)

        XCTAssertNotNil(publicKey, "Failed to generate a pair of RSA keys")
        XCTAssertNotNil(privateKey, "Failed to generate a pair of RSA keys")

        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)
    }

    func testStripPublicKey() {
        // swiftlint:disable line_length
        let encodedPublicKey =
            """
            MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyTyYdSLcMxpHdu7IR6/co0Fti8QyzZ//b9nBeSZaRTynjmQ2/E0SmBzWN6akGLYVL96EXHl5mdYvFKAJZfKuCkiKP29wqjemz93RrMwwNU/AYHzYpUoUTXLDzwfjnzsncx+NMpxwym6A56rZasYyrEjaTrigmduOVPlm77oDlYbK8/PfDBWthuJINo62fOCOoXxkWybtz3y2nvQ2Mhp0xQ6bF0XJ6TtlT83NFs9CZIvKLEQF2cWVsAJtuUfcBj5Nnk0xzDhcpVCMJ61Zo2K03dYZePStvZX4nyb9pLbKaqPN2G1uy7QlGftBFB8p20Zn1j5lx3G+HXKUW76hY5z4QwIDAQAB
            """
        // swiftlint:enable line_length
        guard let publicKey = Data(base64Encoded: encodedPublicKey) else {
            XCTFail("Public key could not be decoded.")
            return
        }
        let strippedKey = encryptor.stripPublicKey(data: publicKey)

        XCTAssertNotNil(strippedKey)

        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.storePublicKey(publicKey: strippedKey!, tag: publicTag)
        let storedKey = encryptor.RSAKey(withTag: publicTag)
        XCTAssertNotNil(storedKey, "Failed to strip and store a public key")
        encryptor.deleteRSAKey(withTag: publicTag)
    }

    func testGenerateRandomByteWithLength() {
        var dataCollection = [Data?]()
        for _ in 0..<10 {
            dataCollection.append(encryptor.generateRandomBytes(length: 16))
        }

        for outerIndex in 0..<10 {
            for innerIndex in outerIndex+1..<10 {
                let data1 = dataCollection[outerIndex]
                let data2 = dataCollection[innerIndex]

                if data1 == data2 {
                    XCTFail("Generated the same random bytes more than once")
                }
            }
        }
    }

    func testRSAWithTag() {

        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)

        encryptor.generateRSAKeyPair(withPublicTag: publicTag, privateTag: privateTag)

        guard encryptor.RSAKey(withTag: publicTag) != nil,
              encryptor.RSAKey(withTag: privateTag) != nil else {
            XCTFail("Unable to retrieve a generated key with tag")
            return
        }

        XCTAssert(true)

        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)
    }

    func testDeleteRSAKeyWithtag() {
        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)

        encryptor.generateRSAKeyPair(withPublicTag: publicTag, privateTag: privateTag)

        guard encryptor.RSAKey(withTag: publicTag) != nil,
              encryptor.RSAKey(withTag: privateTag) != nil else {
            XCTFail("Unable to retrieve a generated key with tag")
            return
        }

        encryptor.deleteRSAKey(withTag: publicTag)
        encryptor.deleteRSAKey(withTag: privateTag)

        let queryAttributes: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: publicTag,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecReturnRef: true
        ]

        var key: CFTypeRef?
        let error = SecItemCopyMatching(queryAttributes, &key)
        XCTAssertEqual(error, errSecItemNotFound, "Retrieved a key that should be deleted already")
    }

    func testEncryptAES() {
        let AESKey = encryptor.generateRandomBytes(length: 32)
        let AESIV = encryptor.generateRandomBytes(length: 16)
        let input = Data([0, 255, 43, 1])
        let output = encryptor.encryptAES(data: input, key: AESKey!, IV: AESIV!)
        XCTAssertEqual(
            output?.count,
            16,
            "AES ciphertext does not have the right length: \(String(describing: output?.count))"
        )
        XCTAssertNotEqual(input, output, "AES does not perform encryption")
    }

    func testEncryptDecryptAES() {
        let AESKey = encryptor.generateRandomBytes(length: 32)
        let AESIV = encryptor.generateRandomBytes(length: 16)
        let input = Data([0, 255, 43, 1])
        let encrypted = encryptor.encryptAES(data: input, key: AESKey!, IV: AESIV!)
        let decrypted = encryptor.decryptAES(data: encrypted!, key: AESKey!, IV: AESIV!)
        XCTAssertEqual(input, decrypted, "AES decryption fails to recover the original data")
    }

    func testGenerateHMACContent() {
        let hmacKey = encryptor.generateRandomBytes(length: 16)
        let input = Data([0, 255, 43, 1])
        let hmac1 = encryptor.generateHMAC(data: input, key: hmacKey!)
        let hmac2 = encryptor.generateHMAC(data: input, key: hmacKey!)
        XCTAssertEqual(hmac1, hmac2, "HMACs generated from the same input do not match")
    }

    func testgenerateUUID() {
        var UUIDCollection = [String]()
        let amount = 100

        for _ in 0..<amount {
            UUIDCollection.append(encryptor.generateUUID())
        }

        for outerIndex in 0..<amount {
            for innerIndex in outerIndex+1..<amount {
                XCTAssertNotEqual(
                    UUIDCollection[outerIndex],
                    UUIDCollection[innerIndex],
                    "Generated the same UUID more than once"
                )
            }
        }
    }
}
