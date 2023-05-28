//
//  RotateResizeModelTests.swift
//  HitStudio
//
//  Created by freegatik on 28.04.2023.
//

import XCTest
@testable import HitStudio

final class RotateResizeModelTests: XCTestCase {
    func testRotateNilOrNilAngleReturnsOriginal() {
        let img = TestImageFactory.solidImage(width: 2, height: 2, r: 1, g: 2, b: 3)
        XCTAssertNil(RotateModel.rotateImage(nil, byAngle: 90))
        let same = RotateModel.rotateImage(img, byAngle: nil)
        XCTAssertTrue(same === img || same?.pngData() == img.pngData())
    }

    func testRotate90ProducesImage() {
        let img = TestImageFactory.solidImage(width: 4, height: 4, r: 200, g: 10, b: 10)
        let out = RotateModel.rotateImage(img, byAngle: 90)
        XCTAssertNotNil(out?.cgImage)
    }

    func testResizeNilReturnsNil() {
        XCTAssertNil(ResizeModel.resizeImage(nil, scale: 1.0))
    }

    func testResizeNilScaleReturnsOriginal() {
        let img = TestImageFactory.solidImage(width: 3, height: 3, r: 5, g: 5, b: 5)
        let out = ResizeModel.resizeImage(img, scale: nil)
        XCTAssertTrue(out === img || out?.pngData() == img.pngData())
    }

    func testResizeScaleUpProducesLargerBitmap() {
        let img = TestImageFactory.solidImage(width: 2, height: 2, r: 100, g: 0, b: 0)
        let out = ResizeModel.resizeImage(img, scale: 2.0)!
        XCTAssertEqual(out.cgImage?.width, 4)
        XCTAssertEqual(out.cgImage?.height, 4)
    }

    func testBilinearInterpolateCornerMatchesPixel() {
        let w = 2, h = 2
        var data: [UInt8] = []
        data.reserveCapacity(w * h * 4)
        for y in 0..<h {
            for x in 0..<w {
                let v = UInt8((x + y * 10) & 0xFF)
                data.append(contentsOf: [v, v, v, 255])
            }
        }
        let c = 0
        let v00 = ResizeModel.bilinearInterpolate(pixelData: data, width: w, height: h, x: 0, y: 0, c: c)
        XCTAssertEqual(v00, 0)
    }
}
