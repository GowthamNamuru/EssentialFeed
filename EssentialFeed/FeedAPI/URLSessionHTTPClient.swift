//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Gowtham Namuri on 21/06/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct  UnExpectedValueRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPURLResult) -> Void) {
        session.dataTask(with: url, completionHandler: {data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnExpectedValueRepresentation()))
            }
        }).resume()
    }
}

