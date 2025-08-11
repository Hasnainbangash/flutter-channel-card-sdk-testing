//
//  SDKConfiguration.swift
//  Runner
//
//  Created by Muhammad Hasnain Bangash on 04/08/2025.
//

import Foundation

struct SDKConfiguration {
    // Make these mutable so Flutter can set them at runtime
    static var rootUrl: String = "https://your-api-url.com"
    static var cardIdentifierId: String = "your-card-identifier"
    static var cardIdentifierType: String = "your-card-type"
    static var bankCode: String = "your-bank-code"
    static var authToken: String = "your-auth-token"

    static func isConfigurationValid() -> Bool {
        // Adjust this validation as needed
        return !rootUrl.contains("your-api-url.com")
            && !cardIdentifierId.contains("your-card-identifier")
            && !cardIdentifierType.contains("your-card-type")
            && !bankCode.contains("your-bank-code")
            && !authToken.isEmpty
    }
}