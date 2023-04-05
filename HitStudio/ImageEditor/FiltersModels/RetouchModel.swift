//
//  RetouchModel.swift
//  HitStudio
//
//  Created by freegatik on 31.03.2023.
//

import SwiftUI
import CoreGraphics

enum RetouchModel {
    static func applyRetouchFilter(_ image: UIImage?, centerX: Int, centerY: Int, radius: Int, retouchStrength: Double) -> UIImage? {
        guard let cgImage = image?.cgImage, radius > 0 else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        var totalAlpha = 0
        var count = 0
        
        for y in max(centerY - radius, 0)..<min(centerY + radius, height) {
            for x in max(centerX - radius, 0)..<min(centerX + radius, width) {
                let dx = x - centerX
                let dy = y - centerY
                let distance = sqrt(Double(dx * dx + dy * dy))
                if distance <= Double(radius) {
                    let index = (x + y * width) * 4
                    totalRed += Int(pixelData[index])
                    totalGreen += Int(pixelData[index + 1])
                    totalBlue += Int(pixelData[index + 2])
                    totalAlpha += Int(pixelData[index + 3])
                    count += 1
                }
            }
        }
        
        if count > 0 {
            let averageRed = UInt8(Double(totalRed) / Double(count))
            let averageGreen = UInt8(Double(totalGreen) / Double(count))
            let averageBlue = UInt8(Double(totalBlue) / Double(count))
            let averageAlpha = UInt8(Double(totalAlpha) / Double(count))
            
            for y in max(centerY - radius, 0)..<min(centerY + radius, height) {
                for x in max(centerX - radius, 0)..<min(centerX + radius, width) {
                    let dx = x - centerX
                    let dy = y - centerY
                    let distance = sqrt(Double(dx * dx + dy * dy))
                    if distance <= Double(radius) {
                        let index = (x + y * width) * 4
                        let weight = 1.0 - (distance / Double(radius))
                        let dynamicStrength = retouchStrength * weight
                        pixelData[index] = UInt8((1.0 - dynamicStrength) * Double(pixelData[index]) + dynamicStrength * Double(averageRed))
                        pixelData[index + 1] = UInt8((1.0 - dynamicStrength) * Double(pixelData[index + 1]) + dynamicStrength * Double(averageGreen))
                        pixelData[index + 2] = UInt8((1.0 - dynamicStrength) * Double(pixelData[index + 2]) + dynamicStrength * Double(averageBlue))
                        pixelData[index + 3] = UInt8((1.0 - dynamicStrength) * Double(pixelData[index + 3]) + dynamicStrength * Double(averageAlpha))
                    }
                }
            }
        }
        
        guard let retouchedContext = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let retouchedImage = retouchedContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: retouchedImage)
    }
}
