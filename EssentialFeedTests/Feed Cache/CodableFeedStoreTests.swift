//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Gowtham Namuri on 03/08/21.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exe = expectation(description: "Wait for retrieval completion")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty, got \(result) instead")
            }
            exe.fulfill()
        }
        wait(for: [exe], timeout: 1.0)
    }

}
