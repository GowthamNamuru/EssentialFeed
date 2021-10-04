//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Gowtham Namuri on 04/10/21.
//

import XCTest
import EssentialFeed


extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exe = expectation(description: "Wait for cache insertion")
        var receievedInsertionError: Error?
        sut.insert(cache.feed, cache.timestamp) { insertionError in
            receievedInsertionError = insertionError
            exe.fulfill()
        }
        wait(for: [exe], timeout: 1.0)
        return receievedInsertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exe = expectation(description: "Wait for deletion to complete")
        var receivedDeletionError: Error?
        sut.deleteCachedFeed { error in
            receivedDeletionError = error
            exe.fulfill()
        }
        wait(for: [exe], timeout: 1.0)
        return receivedDeletionError
    }
    
    func expect(sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toRetrive: expectedResult)
        expect(sut: sut, toRetrive: expectedResult)
    }
    
    func expect(sut: FeedStore, toRetrive expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exe = expectation(description: "Wait for retrieval completion")
        sut.retrieve { retrievalResult in
            switch (retrievalResult, expectedResult) {
            case let (.found(retrievedFeed, retrievedTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            case (.empty, .empty), (.failure, .failure): break
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got and \(retrievalResult) instead", file: file, line: line)
            }
            exe.fulfill()
        }
        wait(for: [exe], timeout: 1.0)
    }
    
}