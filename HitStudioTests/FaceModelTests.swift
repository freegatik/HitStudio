//
//  FaceModelTests.swift
//  HitStudio
//
//  Created by freegatik on 14.05.2023.
//

import XCTest
@testable import HitStudio

final class FaceModelTests: XCTestCase {
    func testDetectFacesInvalidImageReturnsFailure() {
        let exp = expectation(description: "completion")
        let bad = UIImage()
        FaceModel.detectFaces(in: bad) { result in
            switch result {
            case .failure(let err):
                switch err {
                case .invalidImage: break
                default: XCTFail("unexpected error \(err)")
                }
            case .success:
                XCTFail("expected failure")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
}
