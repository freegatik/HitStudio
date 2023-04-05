//
//  FiltersModel.swift
//  HitStudio
//
//  Created by freegatik on 21.03.2023.
//

import SwiftUI
import CoreGraphics

enum FiltersModel {
    static func applyNegativeFilter(_ image: UIImage?) -> UIImage? {
        guard let cgImage = image?.cgImage else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var negativePixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                let index = (x + y * width) * 4
                
                negativePixelData[index] = 255 - pixelData[index]
                negativePixelData[index + 1] = 255 - pixelData[index + 1]
                negativePixelData[index + 2] = 255 - pixelData[index + 2]
                negativePixelData[index + 3] = pixelData[index + 3]
            }
        }
        
        guard let negativeContext = CGContext(data: &negativePixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let negativeImage = negativeContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: negativeImage)
    }
    
    static func applyMosaicFilter(_ image: UIImage?, blockSize: Int?) -> UIImage? {
        guard let cgImage = image?.cgImage, let blockSize = blockSize else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var mosaicPixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                var totalRed = 0
                var totalGreen = 0
                var totalBlue = 0
                var totalAlpha = 0
                
                for i in 0..<blockSize {
                    for j in 0..<blockSize {
                        let pixelX = min(max(x * blockSize + j, 0), width - 1)
                        let pixelY = min(max(y * blockSize + i, 0), height - 1)
                        let index = (pixelX + pixelY * width) * 4
                        
                        totalRed += Int(pixelData[index])
                        totalGreen += Int(pixelData[index + 1])
                        totalBlue += Int(pixelData[index + 2])
                        totalAlpha += Int(pixelData[index + 3])
                    }
                }
                
                let count = blockSize * blockSize
                let averageRed = UInt8(totalRed / count)
                let averageGreen = UInt8(totalGreen / count)
                let averageBlue = UInt8(totalBlue / count)
                let averageAlpha = UInt8(totalAlpha / count)
                
                for i in 0..<blockSize {
                    for j in 0..<blockSize {
                        let pixelX = min(max(x * blockSize + j, 0), width - 1)
                        let pixelY = min(max(y * blockSize + i, 0), height - 1)
                        let index = (pixelX + pixelY * width) * 4
                        
                        mosaicPixelData[index] = averageRed
                        mosaicPixelData[index + 1] = averageGreen
                        mosaicPixelData[index + 2] = averageBlue
                        mosaicPixelData[index + 3] = averageAlpha
                    }
                }
            }
        }
        
        guard let mosaicContext = CGContext(data: &mosaicPixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let mosaicImage = mosaicContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: mosaicImage)
    }
    
    static func applyMedianFilter(_ image: UIImage?) -> UIImage? {
        guard let cgImage = image?.cgImage else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var medianPixelData = [UInt8](repeating: 0, count: width * height * 4)
        let medianSize = 7
        
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                var redValues = [UInt8]()
                var greenValues = [UInt8]()
                var blueValues = [UInt8]()
                var alphaValues = [UInt8]()
                
                for i in -medianSize/2...medianSize/2 {
                    for j in -medianSize/2...medianSize/2 {
                        let pixelX = min(max(x + j, 0), width - 1)
                        let pixelY = min(max(y + i, 0), height - 1)
                        let index = (pixelX + pixelY * width) * 4
                        
                        redValues.append(pixelData[index])
                        greenValues.append(pixelData[index + 1])
                        blueValues.append(pixelData[index + 2])
                        alphaValues.append(pixelData[index + 3])
                    }
                }
                
                redValues.sort()
                greenValues.sort()
                blueValues.sort()
                alphaValues.sort()
                
                let medianIndex = redValues.count / 2
                let medianRed = redValues[medianIndex]
                let medianGreen = greenValues[medianIndex]
                let medianBlue = blueValues[medianIndex]
                let medianAlpha = alphaValues[medianIndex]
                
                let index = (x + y * width) * 4
                medianPixelData[index] = medianRed
                medianPixelData[index + 1] = medianGreen
                medianPixelData[index + 2] = medianBlue
                medianPixelData[index + 3] = medianAlpha
            }
        }
        
        guard let medianContext = CGContext(data: &medianPixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let medianImage = medianContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: medianImage)
    }
    
    static func gaussianBlur(pixelData: [UInt8], width: Int, height: Int, radius: Int = 6) -> [UInt8] {
        let kernelSize = 2 * radius + 1
        let kernel = createGaussianKernel(size: kernelSize, sigma: 2.33)
        var extendedData = Array(repeating: UInt8(0), count: (width + 2 * radius) * (height + 2 * radius) * 4)
        
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                let indexOriginal = (y * width + x) * 4
                let indexExtended = ((y + radius) * (width + 2 * radius) + (x + radius)) * 4
                for c in 0..<4 {
                    extendedData[indexExtended + c] = pixelData[indexOriginal + c]
                }
            }
        }
        
        DispatchQueue.concurrentPerform(iterations: height + 2 * radius) { y in
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
        
        DispatchQueue.concurrentPerform(iterations: height) { y in
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
    
    static func applyGaussianBlurFilter(_ image: UIImage?) -> UIImage? {
        guard let cgImage = image?.cgImage else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var blurPixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        DispatchQueue.concurrentPerform(iterations: height) { y in
            for x in 0..<width {
                let index = (x + y * width) * 4
                
                blurPixelData[index] = pixelData[index]
                blurPixelData[index + 1] = pixelData[index + 1]
                blurPixelData[index + 2] = pixelData[index + 2]
                blurPixelData[index + 3] = pixelData[index + 3]
            }
        }
        
        blurPixelData = gaussianBlur(pixelData: blurPixelData, width: width, height: height)
        
        guard let bluredContext = CGContext(data: &blurPixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let bluredImage = bluredContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: bluredImage)
    }
    
}
