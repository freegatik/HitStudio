//
//  EditImageViewModelPipelineTests.swift
//  HitStudio
//
//  Created by freegatik on 28.05.2023.
//

import XCTest
import Combine
@testable import HitStudio

final class EditImageViewModelPipelineTests: XCTestCase {

    private func waitUntilIdle(_ vm: EditImageViewModel, timeout: TimeInterval = 10, file: StaticString = #filePath, line: UInt = #line) {
        let deadline = Date().addingTimeInterval(timeout)
        while vm.isProcessing {
            XCTAssertLessThan(Date(), deadline, "Timed out waiting for EditImageViewModel.isProcessing == false", file: file, line: line)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.02))
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
    }

    private func seed(_ vm: EditImageViewModel, image: UIImage) {
        vm.originalImage = image
        vm.nonChangedImage = image
    }

    func testApplyNegativeFilterAsyncMatchesModel() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 4, height: 4, r: 10, g: 20, b: 30)
        seed(vm, image: base)
        let expected = FiltersModel.applyNegativeFilter(base)
        vm.applyNegativeFilter()
        waitUntilIdle(vm)
        XCTAssertFalse(vm.isProcessing)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, expected))
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.originalImage, expected))
    }

    func testRotateImageAsyncMatchesModel() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 3, height: 5, r: 40, g: 50, b: 60)
        seed(vm, image: base)
        vm.rotateSliderValue = 90
        let expected = RotateModel.rotateImage(base, byAngle: 90)
        vm.rotateImage()
        waitUntilIdle(vm)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, expected))
    }

    func testResizeImageAsyncMatchesModel() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 8, height: 8, r: 200, g: 10, b: 10)
        seed(vm, image: base)
        vm.resizeSliderValue = 0.5
        let expected = ResizeModel.resizeImage(base, scale: 0.5)
        vm.resizeImage()
        waitUntilIdle(vm)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, expected))
    }

    func testApplyUnsharpMaskAsyncMatchesModel() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 6, height: 6, r: 40, g: 40, b: 40)
        seed(vm, image: base)
        vm.thresholdSliderValue = 1
        vm.amountSliderValue = 10
        vm.radiusSliderValue = 1
        let expected = UnsharpMaskModel.applyUnsharpMask(base, threshold: 1, amount: 10, radius: 1)
        vm.applyUnsharpMask()
        waitUntilIdle(vm)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, expected))
    }

    func testApplyAffineTransformationAsyncMatchesModel() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 8, height: 8, r: 100, g: 50, b: 25)
        seed(vm, image: base)
        let pts: [CGPoint] = [
            CGPoint(x: 0, y: 0), CGPoint(x: 7, y: 0), CGPoint(x: 0, y: 7),
            CGPoint(x: 1, y: 0), CGPoint(x: 6, y: 1), CGPoint(x: 0, y: 6)
        ]
        vm.affinePoints = pts
        let expected = AffineTransformationModel.applyAffineTransformation(base, points: pts)
        vm.applyAffineTransformation()
        waitUntilIdle(vm)
        XCTAssertTrue(vm.affinePoints.isEmpty)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, expected))
    }

    func testNegativeThenRotateChainMatchesSynchronousComposition() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 4, height: 4, r: 10, g: 20, b: 30)
        seed(vm, image: base)
        vm.applyNegativeFilter()
        waitUntilIdle(vm)
        let afterNeg = vm.editedImage!
        vm.rotateSliderValue = 90
        let composed = RotateModel.rotateImage(afterNeg, byAngle: 90)
        vm.rotateImage()
        waitUntilIdle(vm)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, composed))
    }

    func testUndoRedoAfterTwoAsyncOperations() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 4, height: 4, r: 10, g: 20, b: 30)
        seed(vm, image: base)
        let afterNegative = FiltersModel.applyNegativeFilter(base)!
        let composed = RotateModel.rotateImage(afterNegative, byAngle: 90)!

        vm.applyNegativeFilter()
        waitUntilIdle(vm)
        vm.rotateSliderValue = 90
        vm.rotateImage()
        waitUntilIdle(vm)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, composed))

        vm.undo()
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, afterNegative))

        vm.undo()
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, base))

        vm.redo()
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, afterNegative))

        vm.redo()
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, composed))
    }

    func testNegativeThenMosaicChainMatchesSynchronousComposition() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 6, height: 6, r: 80, g: 10, b: 200)
        seed(vm, image: base)
        vm.applyNegativeFilter()
        waitUntilIdle(vm)
        vm.mosaicSliderValue = 3
        vm.applyMosaicFilter()
        waitUntilIdle(vm)
        let composed = FiltersModel.applyMosaicFilter(FiltersModel.applyNegativeFilter(base)!, blockSize: 3)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, composed))
    }

    func testApplyUnsharpMaskAsyncMatchesModelOnBlurredInput() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 8, height: 8, r: 50, g: 120, b: 200)
        let blurred = FiltersModel.applyGaussianBlurFilter(base)!
        seed(vm, image: blurred)
        vm.thresholdSliderValue = 1
        vm.amountSliderValue = 10
        vm.radiusSliderValue = 1
        let expected = UnsharpMaskModel.applyUnsharpMask(blurred, threshold: 1, amount: 10, radius: 1)
        vm.applyUnsharpMask()
        waitUntilIdle(vm)
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, expected))
    }

    func testCombinePublisherFiresWhenProcessingEnds() {
        let vm = EditImageViewModel()
        let base = TestImageFactory.solidImage(width: 2, height: 2, r: 5, g: 6, b: 7)
        seed(vm, image: base)
        let exp = expectation(description: "isProcessing false after work")
        var seenBusy = false
        let sub = vm.$isProcessing
            .receive(on: DispatchQueue.main)
            .sink { busy in
                if busy { seenBusy = true }
                if seenBusy && !busy { exp.fulfill() }
            }
        vm.applyNegativeFilter()
        wait(for: [exp], timeout: 10)
        sub.cancel()
        XCTAssertTrue(TestImageFactory.rgbaBytesEqual(vm.editedImage, FiltersModel.applyNegativeFilter(base)))
    }
}
