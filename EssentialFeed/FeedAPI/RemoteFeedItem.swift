//
//  RemoteFeedImage.swift
//  EssentialFeed
//
//  Created by Gowtham Namuri on 28/07/21.
//

import Foundation

internal struct RemoteFeedImage: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
