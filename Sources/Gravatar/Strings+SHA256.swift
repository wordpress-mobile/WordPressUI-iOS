//
//  Strings+SHA256.swift
//
//
//  Created by Andrew Montgomery on 1/25/24.
//
import CommonCrypto
import CryptoKit

 extension String {
     func sha256() -> String? {
         if #available(iOS 13.0, *) {
             return sha256CryptoKit()
         } else {
             return sha256CommonCrypto()
         }
     }
     
     @available(iOS 13.0, *)
     private func sha256CryptoKit() -> String? {
         guard let data = self.data(using: .utf8) else { return nil }

         let hashed = SHA256.hash(data: data)
         let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
         return hashString
     }
     
     private func sha256CommonCrypto() -> String? {
         guard let data = self.data(using: .utf8) else { return nil }

         var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
         data.withUnsafeBytes {
             _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
         }

         let hashString = hash.map { String(format: "%02x", $0) }.joined()
         return hashString
     }
 }
