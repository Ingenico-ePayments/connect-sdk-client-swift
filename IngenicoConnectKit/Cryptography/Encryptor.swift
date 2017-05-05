//
//  Encryptor.swift
//  IngenicoConnectKit
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import CryptoSwift
import Security

public class Encryptor {
    
    public func generateRSAKeyPair(withPublicTag publicTag: String, privateTag: String) {
        let privateKeyAttr: [String: Any] = [
            kSecAttrIsPermanent as String : true,
            kSecAttrApplicationTag as String  : privateTag
        ]
        
        let publicKeyAttr: [String: Any] = [
            kSecAttrIsPermanent as String : true,
            kSecAttrApplicationTag as String : publicTag
        ]
        
        let keyPairAttr: [String: Any] = [
            kSecAttrKeyType as String : kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String : 2048,
            kSecPrivateKeyAttrs as String : privateKeyAttr,
            kSecPublicKeyAttrs as String : publicKeyAttr
        ]
        
        var publicKey, privateKey: SecKey?
        
        let genStatus = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)
        
        if genStatus != errSecSuccess {
            Macros.DLog(message: "Error while generating pair of RSA keys: \(genStatus)")
            // We cannot call SecCopyErrorMessageString on iOS
        }
    }
    
    public func RSAKey(withTag tag: String) -> (SecKey?) {
        var keyRef: CFTypeRef?
        
        let queryAttr: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag as CFString,
            kSecAttrType: kSecAttrKeyTypeRSA,
            kSecReturnRef: true
        ]
        
        let copyStatus = SecItemCopyMatching(queryAttr, &keyRef)
        if copyStatus != errSecSuccess {
            Macros.DLog(message: "Error while retrieving key with tag \(tag): \(copyStatus)")
        }
        
        return keyRef as! (SecKey?)
    }
    
    public func deleteRSAKey(withTag tag: String) {
        
        let keyAttr: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecAttrKeyType: kSecAttrKeyTypeRSA
        ]
        
        let deleteStatus = SecItemDelete(keyAttr)
        if deleteStatus != errSecSuccess {
            Macros.DLog(message: "Error while deleting h=the key with tag \(tag): \(deleteStatus)")
        }
    }
    
    public func encryptRSA(data: Data, publicKey: SecKey) -> Data {
        let buffer = convertDataToByteArray(data: data)
        return Data(bytes: encryptRSA(plaintext: buffer, publicKey: publicKey))
    }
    
    public func encryptRSA(plaintext: [UInt8], publicKey: SecKey) -> [UInt8] {
        
        var cipherBufferSize = SecKeyGetBlockSize(publicKey)
        var cipherBuffer = [UInt8](repeating: 0, count: cipherBufferSize)
        
        SecKeyEncrypt(publicKey,
                      SecPadding.OAEP,
                      plaintext,
                      plaintext.count,
                      &cipherBuffer,
                      &cipherBufferSize)
        
        return cipherBuffer
    }
    
    public func decryptRSA(data: Data, privateKey: SecKey) -> Data {
        let buffer = convertDataToByteArray(data: data)
        return Data(bytes: decryptRSA(ciphertext: buffer, privateKey: privateKey))
    }
    
    public func decryptRSA(ciphertext: [UInt8], privateKey: SecKey) -> [UInt8] {
        
        var plainBufferSize = SecKeyGetBlockSize(privateKey)
        var plainBuffer = [UInt8](repeating: 0, count: plainBufferSize)
        
        SecKeyDecrypt(privateKey,
                      SecPadding.OAEP,
                      ciphertext,
                      ciphertext.count,
                      &plainBuffer,
                      &plainBufferSize)
        
        return plainBuffer
    }
    
    // A PFX file suited to test the following methods can be generated with the following commands:
    // - openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out certificate.crt
    // - openssl pkcs12 -export -out certificate.pfx -inkey privatekey.key -in certificate.crt
    public func storeRSAKeyPairFromPFXData(PFXData: NSData, password: String, publicTag: String, privateTag: String) -> () {
        var privateKey: SecKey?
        var publicKey: SecKey?
        
        let options: NSDictionary = [kSecImportExportPassphrase: password]
        var items: CFArray?
        
        let importStatus = SecPKCS12Import(PFXData, options, &items)
        if importStatus != errSecSuccess || CFArrayGetCount(items) <= 0 {
            Macros.DLog(message: "Unable to import PKCS #12 data: \(importStatus)")
            return
        }
        
        let identities: NSDictionary = unsafeBitCast(CFArrayGetValueAtIndex(items, 0), to: NSDictionary.self)
        // TODO: make this safer
        let secIdentity: SecIdentity? = identities.value(forKey: kSecImportItemIdentity as String) as! SecIdentity?
        guard let identity = secIdentity else {
            return
        }
        
        let copyPrivateKeyStatus = SecIdentityCopyPrivateKey(identity, &privateKey)
        if copyPrivateKeyStatus != errSecSuccess {
            Macros.DLog(message: "Error while copying private key: \(copyPrivateKeyStatus)")
            return
        }
        
        var certificate: SecCertificate?
        let certificateStatus = SecIdentityCopyCertificate(identity, &certificate)
        if certificateStatus != errSecSuccess {
            Macros.DLog(message: "Error while copying certificate: \(certificateStatus)")
            return
        }
        
        let policy: SecPolicy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        if let cert = certificate {
            SecTrustCreateWithCertificates(cert, policy, &trust)
        } else {
            Macros.DLog(message: "Error while unwrapping certificate")
            return
        }
        
        var result: SecTrustResultType?
        let evaluateTrustStatus = SecTrustEvaluate(trust!, &result!)
        if evaluateTrustStatus != errSecSuccess {
            Macros.DLog(message: "Error while evaluating trust status: \(evaluateTrustStatus)")
        }
        
        publicKey = SecTrustCopyPublicKey(trust!)
        
        if let publicKey = publicKey {
            storeRSAKey(key: publicKey, tag: publicTag)
        }
        
        if let privateKey = privateKey {
            storeRSAKey(key: privateKey, tag: privateTag)
        }
    }
    
    public func storeRSAKey(key: SecKey, tag: String) {
        let keyAttr: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecAttrType: kSecAttrKeyTypeRSA,
            kSecValueRef: key
        ]
        
        let addStatus = SecItemAdd(keyAttr, nil)
        if addStatus != errSecSuccess {
            Macros.DLog(message: "Error while adding key: \(addStatus)")
        }
    }
    
    public func storePublicKey(publicKey: Data, tag: String) {
        let keyAttr: NSDictionary = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecValueData: publicKey as NSData
        ]
        let addStatus = SecItemAdd(keyAttr as CFDictionary, nil)
        if addStatus != errSecSuccess {
            Macros.DLog(message: "Error while adding key: \(addStatus)")
        }
    }
    
    public func stripPublicKey(data: Data) -> (Data?) {
        let publicKey = convertDataToByteArray(data: data)
        if let result = stripPublicKey(publicKey: publicKey) {
            return Data(bytes: result)
        } else {
            return nil
        }
    }
    
    public func stripPublicKey(publicKey: [UInt8]) -> ([UInt8]?) {
        let prefixLength = 24
        let prefix: [UInt8] = [0x30, 0x82, 0x01, 0x22, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0F, 0x00]
        
        for i in 0..<prefixLength where prefix[i] != publicKey[i] {
            Macros.DLog(message: "The provided data has an unexpected format")
            return nil
        }
        
        return Array(publicKey[prefixLength..<publicKey.count])
    }
    
    public func encryptAES(data: Data, key: Data, IV: Data) -> (Data?) {
        let plaintext = convertDataToByteArray(data: data)
        let keyBytes = convertDataToByteArray(data: key)
        let IVBytes = convertDataToByteArray(data: IV)
        
        if let result = encryptAES(plaintext: plaintext, key: keyBytes, IV: IVBytes) {
            return Data(bytes: result)
        }
        return nil
    }
    
    public func encryptAES(plaintext: [UInt8], key: [UInt8], IV: [UInt8]) -> ([UInt8]?) {
        guard let aes = try? AES(key: key, iv: IV, padding: PKCS7()),
              let ciphertext = try? aes.encrypt(plaintext) else
        {
            return nil
        }

        return ciphertext
    }
    
    public func decryptAES(data: Data, key: Data, IV: Data) -> (Data?) {
        let ciphertext = convertDataToByteArray(data: data)
        let keyBytes = convertDataToByteArray(data: key)
        let IVBytes = convertDataToByteArray(data: IV)
        
        if let result = decryptAES(ciphertext: ciphertext, key: keyBytes, IV: IVBytes) {
            return Data(bytes: result)
        }
        return nil
    }
    
    public func decryptAES(ciphertext: [UInt8], key: [UInt8], IV: [UInt8]) -> ([UInt8]?) {
        guard let aes = try? AES(key: key, iv: IV, padding: PKCS7()),
              let plaintext = try? aes.decrypt(ciphertext) else
        {
            return nil
        }

        return plaintext
    }
    
    public func generateHMAC(data: Data, key: Data) -> (Data?) {
        let input = convertDataToByteArray(data: data)
        let keyBytes = convertDataToByteArray(data: key)
        if let hmac = generateHMAC(input: input, key: keyBytes) {
            return Data(bytes: hmac)
        } else {
            return nil
        }
    }
    
    public func generateHMAC(input: [UInt8], key: [UInt8]) -> ([UInt8]?) {
        guard let hmac = try? HMAC(key: key, variant: .sha256).authenticate(input) else {
            return nil
        }

        return hmac
    }
    
    public func generateRandomBytes(length: Int) -> (Data?) {
        return Data(bytes: AES.randomIV(length))
    }
    
    public func generateUUID() -> (String) {
        return UUID().uuidString
    }
    
    private func convertDataToByteArray(data: Data) -> ([UInt8]) {
        var buffer = [UInt8](repeating: 0x0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count * MemoryLayout<UInt8>.size)
        return buffer
    }
}
