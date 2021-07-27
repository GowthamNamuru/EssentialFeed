//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Gowtham Namuri on 27/07/21.
//

import Foundation

public class LocalFeedLoader {
    private var store: FeedStore
    private var currentDate:  () -> Date
    
    public init(store: FeedStore, currentDate:  @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public typealias SaveResult = Error?
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items, currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
    
}
