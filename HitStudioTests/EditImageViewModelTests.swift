//
//  EditImageViewModelTests.swift
//  HitStudio
//
//  Created by freegatik on 06.05.2023.
//

import XCTest
@testable import HitStudio

final class EditImageViewModelTests: XCTestCase {
    func testConvertPointMapsCenterOfAspectFitRegion() {
        let vm = EditImageViewModel()
        let imageSize = CGSize(width: 100, height: 100)
        let viewSize = CGSize(width: 200, height: 200)
        let p = CGPoint(x: 100, y: 100)
        let q = vm.convertPoint(p, fromViewSize: viewSize, toImageSize: imageSize)
        XCTAssertEqual(q.x, 50, accuracy: 0.01)
        XCTAssertEqual(q.y, 50, accuracy: 0.01)
    }

    func testConvertPointAffineReturnsFiniteValues() {
        let vm = EditImageViewModel()
        let imageSize = CGSize(width: 10, height: 10)
        let viewSize = CGSize(width: 20, height: 20)
        let q = vm.convertPointAffine(CGPoint(x: 10, y: 10), fromViewSize: viewSize, toImageSize: imageSize)
        XCTAssertTrue(q.x.isFinite && q.y.isFinite)
    }

    func testUndoRedoStackInitiallyNoOp() {
        let vm = EditImageViewModel()
        vm.undo()
        vm.redo()
        XCTAssertNil(vm.editedImage)
    }

    func testResetClearsStacksWhenNonChangedSet() {
        let vm = EditImageViewModel()
        let img = TestImageFactory.solidImage(width: 2, height: 2, r: 1, g: 2, b: 3)
        vm.nonChangedImage = img
        vm.resetToOriginalImage()
        XCTAssertNotNil(vm.editedImage)
    }
}
