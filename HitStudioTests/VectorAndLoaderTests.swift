//
//  VectorAndLoaderTests.swift
//  HitStudio
//
//  Created by freegatik on 10.05.2023.
//

import XCTest
@testable import HitStudio

final class VectorAndLoaderTests: XCTestCase {
    func testDistanceBetween() {
        let a = CGPoint(x: 0, y: 0)
        let b = CGPoint(x: 3, y: 4)
        XCTAssertEqual(distanceBetween(a, b), 5, accuracy: 0.0001)
    }

    func testAllCubesCasesIncludeFiveColors() {
        let names = Set(AllCubes.allCases.filter { $0 != .clear }.map { cube -> String in
            switch cube {
            case .one: return "green"
            case .two: return "yellow"
            case .three: return "red"
            case .four: return "blue"
            case .five: return "orange"
            default: return ""
            }
        })
        XCTAssertEqual(names.count, 5)
    }

    func testCubesViewModelInitialIndicesCount() {
        let vm = CubesViewModel()
        XCTAssertEqual(vm.allIndicies.count, 6)
        XCTAssertEqual(vm.allCubes.count, AllCubes.allCases.count)
    }
}
