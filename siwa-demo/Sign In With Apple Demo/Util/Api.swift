//
//  Api.swift
//  Sign In With Apple Demo
//
//  Created by n8thnl on 12/28/23.
//

import Foundation

class Api {
    
    // should look something like https://<instanceId>.execute-api.<region>.amazonaws.com/prod
    static let baseUrl = "your-api-gateway-execution-url-with-stage"
    
    static func getJwt(completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: "\(baseUrl)/jwt")!
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    static func getToken(client_id: String, client_secret: String, code: String, completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: "https://appleid.apple.com/auth/token")
        var request = URLRequest(url: url!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: client_id),
            URLQueryItem(name: "client_secret", value: client_secret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        session.dataTask(with: request, completionHandler: completion).resume()
    }
    
    static func postUser(idToken: String, firstName: String, lastName: String, completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: "\(baseUrl)/user")
        var request = URLRequest(url: url!)
        
        let json: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( "Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
    
}
