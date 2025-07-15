//
//  APICallUtil.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

final class APICallUtil {
    
    static let shared = APICallUtil()
    
    private let maxRetry  = 3
    private let baseDelay = 1.0
    
    private init() {}
    
    func fetch<T: Decodable>(returnType _: T.Type, url: URL) async -> Result<T, APICallError> {
        
        var attempt = 0
        var currentDelay = baseDelay
        
        while attempt <= maxRetry {
            do {
                var request = URLRequest(url: url)
                request.setValue("Bearer \(AppSecrets.apiKey)",
                                 forHTTPHeaderField: "Authorization")
                
                print("DEBUG: GET \(url.absoluteString) – attempt \(attempt + 1)")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    
                    if http.statusCode == 429, attempt < maxRetry {
                        currentDelay = await backoff(currentDelay: currentDelay, attempt: attempt)
                        attempt += 1
                        continue
                    }
                    return .failure(.custom("API error \(http.statusCode)"))
                }
                
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return .success(decoded)
                
            } catch let err as URLError {
                
                if isTransient(err), attempt < maxRetry {
                    currentDelay = await backoff(currentDelay: currentDelay, attempt: attempt)
                    attempt += 1
                    continue
                }
                return .failure(.urlSession(err))
                
            } catch let decErr as DecodingError {
                return .failure(.decoding(decErr))
                
            } catch {
                return .failure(.custom(error.localizedDescription))
            }
        }
        
        return .failure(.custom("Max retry limit reached"))
    }
    
    func post<T: Encodable, U: Decodable>(
        returnType _: U.Type,
        url: URL,
        postData: T
    ) async -> Result<U, APICallError> {
        
        var attempt = 0
        var currentDelay = baseDelay
        
        while attempt <= maxRetry {
            do {
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.setValue("Bearer \(AppSecrets.apiKey)", forHTTPHeaderField: "Authorization")
                req.httpBody = try JSONEncoder().encode(postData)
                
                print("DEBUG: POST \(url.absoluteString) – attempt \(attempt + 1)")
                
                let (data, response) = try await URLSession.shared.data(for: req)
                
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    if http.statusCode == 429, attempt < maxRetry {
                        currentDelay = await backoff(currentDelay: currentDelay, attempt: attempt)
                        attempt += 1
                        continue
                    }
                    return .failure(.custom("API error \(http.statusCode)"))
                }
                
                let decoded = try JSONDecoder().decode(U.self, from: data)
                return .success(decoded)
                
            } catch let err as URLError {
                if isTransient(err), attempt < maxRetry {
                    currentDelay = await backoff(currentDelay: currentDelay, attempt: attempt)
                    attempt += 1
                    continue
                }
                return .failure(.urlSession(err))
                
            } catch let decErr as DecodingError {
                return .failure(.decoding(decErr))
                
            } catch {
                return .failure(.custom(error.localizedDescription))
            }
        }
        
        return .failure(.custom("Max retry limit reached"))
    }
    
    private func isTransient(_ err: URLError) -> Bool {
        switch err.code {
        case .timedOut,
                .cannotFindHost,
                .cannotConnectToHost,
                .networkConnectionLost,
                .dnsLookupFailed,
                .notConnectedToInternet:
            return true
        default:
            return false
        }
    }
    
    private func backoff(currentDelay: Double, attempt: Int) async -> Double {
        let jitter = Double.random(in: 0.8...1.2)
        let sleepTime = currentDelay * jitter
        print("DEBUG: Back‑off \(String(format: "%.2f", sleepTime)) s (attempt \(attempt + 1))")
        
        try? await Task.sleep(nanoseconds: UInt64(sleepTime * 1_000_000_000))
        return currentDelay * 2
    }
}
