//
//  OAuthHelper.swift
//  foodScanner_final_project
//
//
// OAuthHelper.swift

import Foundation
import CommonCrypto

extension String {
    func percentEncoded() -> String {
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self
    }
}

func hmacSha1(key: String, data: String) -> Data {
    let keyData = key.data(using: .utf8)!
    let dataData = data.data(using: .utf8)!

    var digest = Data(count: Int(CC_SHA1_DIGEST_LENGTH))

    digest.withUnsafeMutableBytes { digestBytes in
        dataData.withUnsafeBytes { dataBytes in
            keyData.withUnsafeBytes { keyBytes in
                CCHmac(
                    CCHmacAlgorithm(kCCHmacAlgSHA1),
                    keyBytes.baseAddress,
                    keyData.count,
                    dataBytes.baseAddress,
                    dataData.count,
                    digestBytes.baseAddress
                )
            }
        }
    }

    return digest
}
