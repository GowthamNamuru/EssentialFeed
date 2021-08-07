//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Gowtham Namuri on 03/08/21.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {

    
    override func setUp() {
        super.setUp()
        
        setUpEmptyStore()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrive: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toRetrive: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrive_deliversFailureOnRetrievalError() {
        let storeURL = testSpecifiStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: true, encoding: .utf8)
        
        expect(sut: sut, toRetrive: .failure(anyNSError()))
    }
    
    func test_retrive_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecifiStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: true, encoding: .utf8)
        
        expect(sut: sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        
        let latestInsertionError = insert((latestFeed, latestTimeStamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        
        expect(sut: sut, toRetrive: .found(feed: latestFeed, timestamp: latestTimeStamp))
        
    }
    
    
    func test_insert_deliversErrorOnInsertionError() {
        let storeURL = URL(string: "invalidURL://store-com")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to successed")
        expect(sut: sut, toRetrive: .empty)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let insertionError = insert((feed, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to successed")
        
        expect(sut: sut, toRetrive: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePremissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePremissionURL)
        
        let deleteError = deleteCache(from: sut)
        
        XCTAssertNotNil(deleteError, "Expected cache deletion to fail")
        expect(sut: sut, toRetrive: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Wait for Operation 1")
        sut.insert(uniqueImageFeed().local, Date(), completion: { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "Wait for Operation 2")
        sut.deleteCachedFeed(completion: { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        })
        
        let op3 = expectation(description: "Wait for Operation 2")
        sut.retrieve(completion: { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        })
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side effects to run serially but operations finished in wrong order")
    }
    
    // MARK: - HELPERS
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecifiStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exe = expectation(description: "Wait for cache insertion")
        var receievedInsertionError: Error?
        sut.insert(cache.feed, cache.timestamp) { insertionError in
            receievedInsertionError = insertionError
            exe.fulfill()
        }
        wait(for: [exe], timeout: 1.0)
        return receievedInsertionError
    }
    
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exe = expectation(description: "Wait for deletion to complete")
        var receivedDeletionError: Error?
        sut.deleteCachedFeed { error in
            receivedDeletionError = error
            exe.fulfill()
        }
        wait(for: [exe], timeout: 1.0)
        return receivedDeletionError
    }
    
    private func expect(sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toRetrive: expectedResult)
        expect(sut: sut, toRetrive: expectedResult)
    }
    
    private func expect(sut: FeedStore, toRetrive expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    private func testSpecifiStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setUpEmptyStore() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecifiStoreURL())
    }
    
}
