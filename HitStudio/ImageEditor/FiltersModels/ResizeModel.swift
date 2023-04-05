//
//  ResizeModel.swift
//  HitStudio
//
//  Created by freegatik on 25.03.2023.
//

import SwiftUI
import CoreGraphics

enum ResizeModel {
    static func bilinearInterpolate(pixelData: [UInt8], width: Int, height: Int, x: CGFloat, y: CGFloat, c: Int) -> UInt8 {
        let xInt = Int(x)
        let yInt = Int(y)
        
        let xFract = x - CGFloat(xInt)
        let yFract = y - CGFloat(yInt)
        
        let indexTL = ((yInt * width + xInt) * 4) + c
        let indexTR = ((yInt * width + min(xInt + 1, width - 1)) * 4) + c
        let indexBL = ((min(yInt + 1, height - 1) * width + xInt) * 4) + c
        let indexBR = ((min(yInt + 1, height - 1) * width + min(xInt + 1, width - 1)) * 4) + c
        
        let topLeft = CGFloat(pixelData[indexTL])
        let topRight = CGFloat(pixelData[indexTR])
        let bottomLeft = CGFloat(pixelData[indexBL])
        let bottomRight = CGFloat(pixelData[indexBR])
        
        let top = (1 - xFract) * topLeft + xFract * topRight
        let bottom = (1 - xFract) * bottomLeft + xFract * bottomRight
        
        let result = (1 - yFract) * top + yFract * bottom
        
        return UInt8(max(0, min(255, result.rounded())))
    }
    
    static func trilinearInterpolate(pixelData1: [UInt8], pixelData2: [UInt8], width: Int, height: Int, x: CGFloat, y: CGFloat, mip: CGFloat, c: Int) -> UInt8 {
        let result1 = bilinearInterpolate(pixelData: pixelData1, width: width, height: height, x: x, y: y, c: c)
        let result2 = bilinearInterpolate(pixelData: pixelData2, width: width, height: height, x: x, y: y, c: c)
        
        let mipFract = mip - CGFloat(Int(mip))
        let finalResult = (1 - mipFract) * CGFloat(result1) + mipFract * CGFloat(result2)
        
        return UInt8(max(0, min(255, finalResult.rounded())))
    }
    
    static func gaussianBlur(pixelData: [UInt8], width: Int, height: Int, radius: Int = 1) -> [UInt8] {
        let kernelSize = 2 * radius + 1
        let kernel = createGaussianKernel(size: kernelSize, sigma: 1)
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
        
        DispatchQueue.concurrentPerform(iterations: height + 2 * radius) { y in
            DispatchQueue.concurrentPerform(iterations: width + 2 * radius) { x in
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
            DispatchQueue.concurrentPerform(iterations: width) { x in
                var sum = [CGFloat](repeating: 0.0, count: 4)
                let kernelSize = 2 * radius + 1
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
    
    static func resizeImage(_ image: UIImage?, scale: Double?, zScale: CGFloat = 2.0) -> UIImage? {
        guard let cgImage = image?.cgImage else {
            return image
        }
        
        guard let scale = scale else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData: [UInt8] = Array(repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let newWidth = Int(CGFloat(width) * CGFloat(scale))
        let newHeight = Int(CGFloat(height) * CGFloat(scale))
        var resizedPixelData: [UInt8] = Array(repeating: 0, count: newWidth * newHeight * 4)
        
        DispatchQueue.concurrentPerform(iterations: newHeight) { y in
            DispatchQueue.concurrentPerform(iterations: newWidth) { x in
                let sourceIndex = (x + y * newWidth) * 4
                for c in 0..<4 {
                    if scale > 1 {
                        resizedPixelData[sourceIndex + c] = bilinearInterpolate(pixelData: pixelData, width: width, height: height, x: CGFloat(x) / CGFloat(scale), y: CGFloat(y) / CGFloat(scale), c: c)
                    } else {
                        resizedPixelData[sourceIndex + c] = trilinearInterpolate(pixelData1: pixelData, pixelData2: pixelData, width: width, height: height, x: CGFloat(x) / CGFloat(scale), y: CGFloat(y) / CGFloat(scale), mip: CGFloat(scale), c: c)
                    }
                }
            }
        }
        
        if scale < 1 && min(newWidth, newHeight) < 800 {
            resizedPixelData = gaussianBlur(pixelData: resizedPixelData, width: newWidth, height: newHeight)
        }
        
        guard let resizedContext = CGContext(data: &resizedPixelData, width: newWidth, height: newHeight, bitsPerComponent: 8, bytesPerRow: newWidth * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let resizedImage = resizedContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: resizedImage)
    }
}
