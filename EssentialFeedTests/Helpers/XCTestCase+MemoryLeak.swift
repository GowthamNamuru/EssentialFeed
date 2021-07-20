//
//  XCTestCase+MemoryLeak.swift
//  EssentialFeedTests
//
//  Created by Gowtham Namuri on 16/06/21.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential Memory leak", file: file, line: line)
        }
    }
}


