//
//  SDKConfiguration.swift
//  Runner
//
//  Created by Muhammad Hasnain Bangash on 04/08/2025.
//

import Foundation

struct SDKConfiguration {
    // TODO: Replace these with your actual configuration values
    static let rootUrl = "https://your-api-url.com"
    static let cardIdentifierId = "your-card-identifier"
    static let cardIdentifierType = "your-card-type"
    static let bankCode = "your-bank-code"
    
    // Add any other configuration values you need
    static let authToken = "your-auth-token"
}

// If you have additional configuration methods, add them here
extension SDKConfiguration {
    // Example: method to validate configuration
    static func isConfigurationValid() -> Bool {
        return !rootUrl.contains("your-api-url.com") &&
               !cardIdentifierId.contains("your-card-identifier") &&
               !cardIdentifierType.contains("your-card-type") &&
               !bankCode.contains("your-bank-code")
    }
}
