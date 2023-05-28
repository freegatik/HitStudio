//
//  AffineUnsharpRetouchTests.swift
//  HitStudio
//
//  Created by freegatik on 02.05.2023.
//

import XCTest
@testable import HitStudio

final class AffineUnsharpRetouchTests: XCTestCase {
    func testGetTransformationMatrixIdentityStyle() {
        let src = [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1)]
        let dst = [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1)]
        let m = AffineTransformationModel.getTransformationMatrix(srcPoints: src, dstPoints: dst)
        XCTAssertEqual(m.count, 6)
        XCTAssertTrue(m.allSatisfy { $0.isFinite })
    }

    func testApplyAffineNilPointsReturnsImageUnchanged() {
        let img = TestImageFactory.solidImage(width: 2, height: 2, r: 1, g: 2, b: 3)
        let out = AffineTransformationModel.applyAffineTransformation(img, points: nil)
        XCTAssertNotNil(out)
        XCTAssertEqual(out?.pngData(), img.pngData())
    }

    func testApplyAffineNilImageReturnsNil() {
        XCTAssertNil(AffineTransformationModel.applyAffineTransformation(nil, points: []))
    }

    func testUnsharpMaskGaussianBlurSmallBuffer() {
        let w = 3, h = 3
        var data = [UInt8](repeating: 128, count: w * h * 4)
        for i in stride(from: 3, to: data.count, by: 4) {
            data[i] = 255
        }
        let blurred = UnsharpMaskModel.gaussianBlur(pixelData: data, width: w, height: h, radius: 1)
        XCTAssertEqual(blurred.count, data.count)
    }

    func testApplyUnsharpMaskNilReturnsNil() {
        XCTAssertNil(UnsharpMaskModel.applyUnsharpMask(nil, threshold: 1, amount: 1, radius: 1))
    }

    func testRetouchNilOrZeroRadiusReturnsOriginal() {
        XCTAssertNil(RetouchModel.applyRetouchFilter(nil, centerX: 1, centerY: 1, radius: 5, retouchStrength: 0.5))
        let img = TestImageFactory.solidImage(width: 4, height: 4, r: 10, g: 20, b: 30)
        let out = RetouchModel.applyRetouchFilter(img, centerX: 2, centerY: 2, radius: 0, retouchStrength: 0.5)
        XCTAssertTrue(out === img || out?.pngData() == img.pngData())
    }

    func testRetouchProducesImage() {
        let img = TestImageFactory.solidImage(width: 8, height: 8, r: 200, g: 100, b: 50)
        let out = RetouchModel.applyRetouchFilter(img, centerX: 4, centerY: 4, radius: 3, retouchStrength: 0.3)
        XCTAssertNotNil(out?.cgImage)
    }
}
