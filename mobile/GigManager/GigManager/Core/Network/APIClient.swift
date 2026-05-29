//
//  APIClient.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case notFound
    case serverError(Int)
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid request URL"
        case .unauthorized: "Session expired. Please sign in again"
        case .notFound: "The requested resource was not found"
        case .serverError(let code): "Server error (\(code)). Please try again"
        case .decodingFailed: "Unexpected response from server"
        }
    }
}

struct APIClient: Sendable {
    
    private let base = NetworkClient.baseURL
    
    private static let localDateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    private func decoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
            let parts = raw.split(separator: ".", maxSplits: 1)
            guard let date = APIClient.localDateTimeFormatter.date(from: String(parts[0])) else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath,
                          debugDescription: "Date does not match expected format: \(raw)")
                )
            }
            guard parts.count == 2, let fraction = Double("0.\(parts[1])") else {
                return date
            }
            return date.addingTimeInterval(fraction)
        }
        return d
    }
    
    private func authorizedRequest(_ path: String, method: String, token: String) throws -> URLRequest {
        guard let url = URL(string: base + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func checkStatus(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200...299: break
        case 401: throw APIError.unauthorized
        case 404: throw APIError.notFound
        default: throw APIError.serverError(http.statusCode)
        }
    }
    
    func get<T: Decodable>(_ path: String, token: String) async throws -> T {
        let request = try authorizedRequest(path, method: "GET", token: token)
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response)
        do {
            return try decoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
    
    func post<Body: Encodable, T: Decodable>(_ path: String, body: Body, token: String) async throws -> T {
        var request = try authorizedRequest(path, method: "POST", token: token)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response)
        do {
            return try decoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
    
    func put<Body: Encodable, T: Decodable>(_ path: String, body: Body, token: String) async throws -> T {
              var request = try authorizedRequest(path, method: "PUT", token: token)
              request.setValue("application/json", forHTTPHeaderField: "Content-Type")
              request.httpBody = try JSONEncoder().encode(body)
              let (data, response) = try await URLSession.shared.data(for: request)
              try checkStatus(response)
              do {
                  return try decoder().decode(T.self, from: data)
              } catch {
                  throw APIError.decodingFailed(error)
              }
          }

    func delete(_ path: String, token: String) async throws {
        let request = try authorizedRequest(path, method: "DELETE", token: token)
        let (_, response) = try await URLSession.shared.data(for: request)
        try checkStatus(response)
    }
}
