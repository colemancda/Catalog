//
//  AuthenticationToken.swift
//  CoreCerradura
//
//  Created by Alsey Coleman Miller on 5/3/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import SwiftFoundation
import OpenSSL

public extension AuthenticationContext {
    
    /// Generates the authentication token used for authenticating requests.
    ///
    /// Modeled after [AWS](http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#UsingTemporarySecurityCredentials)
    ///
    /// - Parameter identifier: The identifier (e.g. resource ID or username) of the entity trying to authenticate.
    /// - Parameter secret: The secret (e.g. password) of the entity trying to authenticate.
    /// - Returns: The generated authentication token.
    func generateToken(identifier: String, secret: String) -> String {
        
        let stringToSign = self.concatenatedString
        
        let signature: Data
        
        do {
            
            let digestLength = Int(SHA256_DIGEST_LENGTH)
            
            let algorithm = EVP_sha256()
            
            let secretData = secret.toUTF8Data()
            
            let stringToSignData = stringToSign.toUTF8Data()
            
            let result = UnsafeMutablePointer<Byte>.alloc(digestLength)
            
            defer { result.dealloc(digestLength) }
            
            var resultLength = UInt32(digestLength) // SHA256 digest length
            
            HMAC(algorithm, secretData, Int32(secretData.count), stringToSignData, stringToSignData.count, result, &resultLength)
            
            let resultData = DataFromBytePointer(result, length: digestLength)
            
            signature = resultData
        }
        
        let base64SignatureData = Base64.encode(signature)
        
        guard let base64Signature = String(UTF8Data: base64SignatureData)
            else { fatalError("Could not create string from Base64 data") }
        
        return base64Signature
    }
}


