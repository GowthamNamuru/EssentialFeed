//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Gowtham Namuri on 10/06/21.
//

import Foundation

public enum HTTPURLResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPURLResult) -> Void)
}
