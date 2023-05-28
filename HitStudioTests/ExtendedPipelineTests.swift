//
//  ExtendedPipelineTests.swift
//  HitStudio
//
//  Created by freegatik on 22.05.2023.
//

import XCTest
@testable import HitStudio
import SceneKit

final class VectorSplineInterpolationTests: XCTestCase {
    func testSplineInterpolationEmptyWhenFewerThanTwoPoints() {
        let v = VectorView()
        XCTAssertTrue(v.splineInterpolation(points: []).isEmpty)
        XCTAssertTrue(v.splineInterpolation(points: [CGPoint(x: 1, y: 1)]).isEmpty)
    }

    func testSplineInterpolationProducesManyPointsForSegment() {
        let v = VectorView()
        let pts = [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0), CGPoint(x: 10, y: 10)]
        let spline = v.splineInterpolation(points: pts)
        XCTAssertGreaterThan(spline.count, 100)
    }
}

final class CubeSceneCreationTests: XCTestCase {
    func testCreateSceneHasCubeAndCamera() {
        let scene = CubeView().createScene()
        XCTAssertGreaterThanOrEqual(scene.rootNode.childNodes.count, 2)
        XCTAssertTrue(scene.rootNode.childNodes.contains { $0.camera != nil })
        XCTAssertTrue(scene.rootNode.childNodes.contains { $0.geometry is SCNBox })
    }
}

final class AffineApplyPipelineTests: XCTestCase {
    func testApplyAffineWithSixPointsReturnsImage() {
        let img = TestImageFactory.solidImage(width: 8, height: 8, r: 100, g: 50, b: 25)
        let pts: [CGPoint] = [
            CGPoint(x: 0, y: 0), CGPoint(x: 7, y: 0), CGPoint(x: 0, y: 7),
            CGPoint(x: 1, y: 0), CGPoint(x: 6, y: 1), CGPoint(x: 0, y: 6)
        ]
        let out = AffineTransformationModel.applyAffineTransformation(img, points: pts)
        XCTAssertNotNil(out?.cgImage)
        XCTAssertGreaterThan(out?.cgImage?.width ?? 0, 0)
        XCTAssertGreaterThan(out?.cgImage?.height ?? 0, 0)
        XCTAssertNotEqual(TestImageFactory.rgbaChecksum(img), TestImageFactory.rgbaChecksum(out))
    }
}

final class UnsharpMaskApplyPipelineTests: XCTestCase {
    func testApplyUnsharpMaskProducesImage() {
        let img = TestImageFactory.solidImage(width: 6, height: 6, r: 40, g: 40, b: 40)
        let out = UnsharpMaskModel.applyUnsharpMask(img, threshold: 1, amount: 10, radius: 1)
        XCTAssertNotNil(out?.cgImage)
    }
}

final class ResizeDownscaleTests: XCTestCase {
    func testResizeScaleDownHalvesDimensions() {
        let img = TestImageFactory.solidImage(width: 8, height: 8, r: 200, g: 10, b: 10)
        let out = ResizeModel.resizeImage(img, scale: 0.5)
        XCTAssertEqual(out?.cgImage?.width, 4)
        XCTAssertEqual(out?.cgImage?.height, 4)
    }
}

final class EditImageViewModelGeometryTests: XCTestCase {
    func testCheckIfEqualsDetectsDuplicate() {
        let vm = EditImageViewModel()
        vm.affinePoints = [CGPoint(x: 1, y: 1)]
        XCTAssertTrue(vm.checkIfEquals(point: CGPoint(x: 1, y: 1)))
        XCTAssertFalse(vm.checkIfEquals(point: CGPoint(x: 2, y: 2)))
    }

    func testAddAffinePointAppends() {
        let vm = EditImageViewModel()
        vm.editedImage = TestImageFactory.solidImage(width: 10, height: 10, r: 1, g: 2, b: 3)
        vm.addAffinePoint(at: CGPoint(x: 5, y: 5), in: CGSize(width: 10, height: 10))
        XCTAssertEqual(vm.affinePoints.count, 1)
    }
}
