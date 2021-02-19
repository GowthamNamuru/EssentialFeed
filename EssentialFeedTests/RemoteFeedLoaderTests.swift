//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Gowtham on 17/02/21.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}


class RemoteFeedLoaderTests: XCTestCase {

    class HTTPClientSpy: HTTPClient {
        func get(from url: URL) {
            requestedURL = url
        }
        var requestedURL: URL?
    }
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: URL(string: "https://a-url.com")!, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
 
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
         
        XCTAssertEqual(client.requestedURL, url)
    }
    
}
