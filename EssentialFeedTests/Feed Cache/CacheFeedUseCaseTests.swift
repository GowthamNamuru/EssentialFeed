//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Gowtham Namuri on 19/07/21.
//

import XCTest

class LocalFeedLoader {
    
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCacheFeedCallCount = 0
}


class CacheFeedUseCaseTests: XCTestCase {

    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }

}
