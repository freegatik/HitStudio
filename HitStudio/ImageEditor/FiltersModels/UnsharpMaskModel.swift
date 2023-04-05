//
//  UnsharpMaskModel.swift
//  HitStudio
//
//  Created by freegatik on 29.03.2023.
//

import SwiftUI
import CoreGraphics

enum UnsharpMaskModel {
    static func gaussianBlur(pixelData: [UInt8], width: Int, height: Int, radius: Int) -> [UInt8] {
        let kernelSize = 2 * radius + 1
        let kernel = createGaussianKernel(size: kernelSize, sigma: 1.5)
        var extendedData = Array(repeating: UInt8(0), count: (width + 2 * radius) * (height + 2 * radius) * 4)
        
        for y in 0..<height {
            for x in 0..<width {
                let indexOriginal = (y * width + x) * 4
                let indexExtended = ((y + radius) * (width + 2 * radius) + (x + radius)) * 4
                for c in 0..<4 {
                    extendedData[indexExtended + c] = pixelData[indexOriginal + c]
                }
            }
        }
        
        for y in 0..<height + 2 * radius {
            for x in 0..<width + 2 * radius {
                if y < radius || y >= height + radius || x < radius || x >= width + radius {
                    let nearestY = min(max(y, radius), height + radius - 1)
                    let nearestX = min(max(x, radius), width + radius - 1)
                    let indexExtended = (y * (width + 2 * radius) + x) * 4
                    let indexNearest = (nearestY * (width + 2 * radius) + nearestX) * 4
                    for c in 0..<4 {
                        extendedData[indexExtended + c] = extendedData[indexNearest + c]
                    }
                }
            }
        }
        
        var blurredData = Array(repeating: UInt8(0), count: width * height * 4)
        
        for y in 0..<height {
            for x in 0..<width {
                var sum = [CGFloat](repeating: 0.0, count: 4)
                for ky in 0..<kernelSize {
                    let ny = y + ky
                    for kx in 0..<kernelSize {
                        let nx = x + kx
                        let weight = kernel[ky * kernelSize + kx]
                        let index = (ny * (width + 2 * radius) + nx) * 4
                        for c in 0..<4 {
                            sum[c] += CGFloat(extendedData[index + c]) * weight
                        }
                    }
                }
                let index = (y * width + x) * 4
                for c in 0..<4 {
                    blurredData[index + c] = UInt8(min(max(Int(sum[c].rounded()), 0), 255))
                }
            }
        }
        
        return blurredData
    }
    
    private static func createGaussianKernel(size: Int, sigma: CGFloat) -> [CGFloat] {
        let center = size / 2
        var kernel = [CGFloat](repeating: 0, count: size * size)
        var sum: CGFloat = 0
        
        for i in 0..<size {
            for j in 0..<size {
                let x = CGFloat(i - center)
                let y = CGFloat(j - center)
                let exponent = -(x*x + y*y) / (2 * sigma * sigma)
                kernel[i * size + j] = exp(exponent)
                sum += kernel[i * size + j]
            }
        }
        
        for i in 0..<size*size {
            kernel[i] /= sum
        }
        
        return kernel
    }
    
    static func applyUnsharpMask(_ image: UIImage?, threshold: Int?, amount: Int?, radius: Int?) -> UIImage? {
        guard let cgImage = image?.cgImage, let threshold = threshold, let amount = amount, let radius = radius else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var maskedPixelData = pixelData
        let bluredPixelData = gaussianBlur(pixelData: pixelData, width: width, height: height, radius: radius)
        let k: Double = Double(2 * amount / 100)
        
        for y in 0..<height {
            for x in 0..<width {
                for c in 0..<4 {
                    let index = (x + y * width) * 4 + c
                    let value1: Int32 = Int32(pixelData[index])
                    let value2: Int32 = Int32(bluredPixelData[index])
                    let difference: UInt8 = UInt8(abs(value1 - value2))
                    
                    if difference >= threshold {
                        let dk = Int32(Double(difference) * k)
                        let val = UInt8(max(min(value1 + dk, 255), 0))
                        maskedPixelData[index] = val
                    }
                }
            }
        }
        
        guard let maskedContext = CGContext(data: &maskedPixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let maskedImage = maskedContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: maskedImage)
    }
}
