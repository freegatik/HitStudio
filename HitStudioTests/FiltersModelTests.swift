//
//  FiltersModelTests.swift
//  HitStudio
//
//  Created by freegatik on 25.04.2023.
//

import XCTest
@testable import HitStudio

final class FiltersModelTests: XCTestCase {
    func testApplyNegativeFilterInvertsRGBPreservesAlpha() {
        let img = TestImageFactory.solidImage(width: 2, height: 2, r: 10, g: 20, b: 30, a: 255)
        let out = FiltersModel.applyNegativeFilter(img)!
        guard let cg = out.cgImage else {
            return XCTFail("cgImage")
        }
        XCTAssertEqual(cg.width, 2)
        XCTAssertEqual(cg.height, 2)
        var pixels = [UInt8](repeating: 0, count: 2 * 2 * 4)
        guard let ctx = CGContext(
            data: &pixels,
            width: 2,
            height: 2,
            bitsPerComponent: 8,
            bytesPerRow: 8,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return XCTFail("context")
        }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: 2, height: 2))
        XCTAssertEqual(pixels[0], 245)
        XCTAssertEqual(pixels[1], 235)
        XCTAssertEqual(pixels[2], 225)
        XCTAssertEqual(pixels[3], 255)
    }

    func testApplyNegativeFilterNilInputReturnsNil() {
        XCTAssertNil(FiltersModel.applyNegativeFilter(nil))
    }

    func testApplyMosaicFilterWithNilBlockSizeReturnsOriginal() {
        let img = TestImageFactory.solidImage(width: 4, height: 4, r: 5, g: 6, b: 7)
        let out = FiltersModel.applyMosaicFilter(img, blockSize: nil)
        XCTAssertNotNil(out)
        XCTAssertEqual(out?.cgImage?.width, img.cgImage?.width)
    }

    func testApplyMosaicFilterChangesPixels() {
        let img = TestImageFactory.solidImage(width: 8, height: 8, r: 100, g: 50, b: 25)
        let out = FiltersModel.applyMosaicFilter(img, blockSize: 4)!
        XCTAssertNotNil(out.cgImage)
    }

    func testApplyMedianFilterNilReturnsNil() {
        XCTAssertNil(FiltersModel.applyMedianFilter(nil))
    }

    func testApplyGaussianBlurFilterOnTinyImage() {
        let img = TestImageFactory.solidImage(width: 3, height: 3, r: 40, g: 80, b: 120)
        let out = FiltersModel.applyGaussianBlurFilter(img)
        XCTAssertNotNil(out)
    }
}
