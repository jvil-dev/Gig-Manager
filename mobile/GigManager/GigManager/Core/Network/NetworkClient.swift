//
//  NetworkClient.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/26/26.
//

// MARK: - Network Client
// Base URL config. DEBUG targets local dev server; Release targets production

import Foundation

enum NetworkClient {
    #if DEBUG
    static let baseURL = "http://localhost:8080"
    #else
    static let baseURL = "https://api.gig-manager.com"
    #endif
}
