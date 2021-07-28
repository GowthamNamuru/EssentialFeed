//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Gowtham Namuri on 27/07/21.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem],_ timestamp: Date, completion: @escaping InsertionCompletion)
}
