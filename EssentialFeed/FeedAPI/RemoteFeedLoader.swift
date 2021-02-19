//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Gowtham on 19/02/21.
//

import Foundation

public enum HTTPURLResult {
    case success(HTTPURLResponse)
    case failure(Error)
}


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPURLResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completionHandler: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completionHandler(.invalidData)
            case .failure:
                completionHandler(.connectivity)
            }
        }
    }
}

