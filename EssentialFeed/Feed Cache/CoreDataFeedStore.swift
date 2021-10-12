//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Gowtham Namuri on 12/10/21.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() { }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
