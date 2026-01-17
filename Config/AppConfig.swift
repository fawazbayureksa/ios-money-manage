//
//  AppConfig.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 11/01/26.
//

import Foundation

enum AppConfig {
    static var apiBaseURL: String {
        // Try to get from Info.plist first (if xcconfig is properly linked)
//        if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
//            return url
//        }
        return "http://34.158.34.129:8080/api"
    }
    
    static var appName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "APP_NAME") as? String {
            return name
        }
        return "Money Manage"
    }
}
