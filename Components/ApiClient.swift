//
//  ApiClient.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 11/01/26.
//

import Foundation

enum ApiClient {
    static var apiBaseURL: String {
        Bundle.main.object(
            forInfoDictionaryKey: "API_BASE_URL"
        ) as? String ?? ""
    }
}

