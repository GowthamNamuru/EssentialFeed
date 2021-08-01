//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Gowtham Namuri on 01/08/21.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 1)
}
