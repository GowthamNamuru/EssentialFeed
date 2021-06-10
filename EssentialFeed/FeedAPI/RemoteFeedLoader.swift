//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Gowtham on 19/02/21.
//

import Foundation
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completionHandler: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                completionHandler(FeedItemsMapper.map(data, from: response))
            case .failure:
                completionHandler(.failure(.connectivity))
            }
        }
    }
}
