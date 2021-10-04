//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Gowtham Namuri on 03/08/21.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {

    
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
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        
        let insertionError = insert((latestFeed, latestTimeStamp), to: sut)
        XCTAssertNil(insertionError, "Expected to override cache successfully")
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        insert((latestFeed, latestTimeStamp), to: sut)
        
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
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let storeURL = URL(string: "invalidURL://store-com")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toRetrive: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to successed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        deleteCache(from: sut)
        
        expect(sut: sut, toRetrive: .empty)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        insert((feed, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to successed")
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        insert((feed, Date()), to: sut)
        deleteCache(from: sut)
        
        expect(sut: sut, toRetrive: .empty)
    }
    // Fix me!
    func ignoretest_delete_deliversErrorOnDeletionError() {
        let noDeletePremissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePremissionURL)

        let deleteError = deleteCache(from: sut)

        XCTAssertNotNil(deleteError, "Expected cache deletion to fail")
        expect(sut: sut, toRetrive: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, Date(), completion: { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed(completion: { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        })
        
        let op3 = expectation(description: "Operation 2")
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
