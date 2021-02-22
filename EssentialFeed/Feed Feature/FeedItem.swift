//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Gowtham on 17/02/21.
//

import Foundation



public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
