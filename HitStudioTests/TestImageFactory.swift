//
//  TestImageFactory.swift
//  HitStudio
//
//  Created by freegatik on 18.05.2023.
//

import UIKit
import CoreGraphics

enum TestImageFactory {
    static func solidImage(width: Int, height: Int, r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        defer { UIGraphicsEndImageContext() }
        let color = UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    static func premultipliedRGBABytes(_ image: UIImage) -> (width: Int, height: Int, bytes: [UInt8])? {
        guard let cg = image.cgImage else { return nil }
        let w = cg.width
        let h = cg.height
        let bytesPerRow = w * 4
        var pixels = [UInt8](repeating: 0, count: bytesPerRow * h)
        guard let ctx = CGContext(
            data: &pixels,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        return (w, h, pixels)
    }

    static func rgbaBytesEqual(_ a: UIImage?, _ b: UIImage?) -> Bool {
        guard let a, let b, let da = premultipliedRGBABytes(a), let db = premultipliedRGBABytes(b) else { return false }
        return da.width == db.width && da.height == db.height && da.bytes == db.bytes
    }

    static func rgbaChecksum(_ image: UIImage?) -> UInt64? {
        guard let image, let (_, _, bytes) = premultipliedRGBABytes(image) else { return nil }
        var hash: UInt64 = 14_695_981_039_346_656_037
        for b in bytes {
            hash ^= UInt64(b)
            hash &*= 1_099_511_628_211
        }
        return hash
    }
}
