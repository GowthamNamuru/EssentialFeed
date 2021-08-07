//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Gowtham Namuri on 27/07/21.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case failure(Error)
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clents are responsible to dispatch to appropiate thread, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clents are responsible to dispatch to appropiate thread, if needed.
    func insert(_ feed: [LocalFeedImage],_ timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clents are responsible to dispatch to appropiate thread, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
