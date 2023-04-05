//
//  AffineTransformationModel.swift
//  HitStudio
//
//  Created by freegatik on 27.03.2023.
//

import SwiftUI
import CoreGraphics

enum AffineTransformationModel {
    static func getTransformationMatrix(srcPoints: [CGPoint], dstPoints: [CGPoint]) -> [Double] {
        var transformationMatrix = [Double](repeating: 0, count: 6)
        
        let det = srcPoints[0].x * (srcPoints[1].y - srcPoints[2].y) + srcPoints[1].x * (srcPoints[2].y - srcPoints[0].y) + srcPoints[2].x * (srcPoints[0].y - srcPoints[1].y)
        
        transformationMatrix[0] = Double((dstPoints[0].x * (srcPoints[1].y - srcPoints[2].y) + dstPoints[1].x * (srcPoints[2].y - srcPoints[0].y) + dstPoints[2].x * (srcPoints[0].y - srcPoints[1].y)) / det)
        
        transformationMatrix[1] = Double((dstPoints[0].x * (srcPoints[2].x - srcPoints[1].x) + dstPoints[1].x * (srcPoints[0].x - srcPoints[2].x) + dstPoints[2].x * (srcPoints[1].x - srcPoints[0].x)) / det)
        
        transformationMatrix[2] = Double((dstPoints[0].x * (srcPoints[1].x * srcPoints[2].y - srcPoints[2].x * srcPoints[1].y) + dstPoints[1].x * (srcPoints[2].x * srcPoints[0].y - srcPoints[0].x * srcPoints[2].y) + dstPoints[2].x * (srcPoints[0].x * srcPoints[1].y - srcPoints[1].x * srcPoints[0].y)) / det)
        
        transformationMatrix[3] = Double((dstPoints[0].y * (srcPoints[1].y - srcPoints[2].y) + dstPoints[1].y * (srcPoints[2].y - srcPoints[0].y) + dstPoints[2].y * (srcPoints[0].y - srcPoints[1].y)) / det)
        
        transformationMatrix[4] = Double((dstPoints[0].y * (srcPoints[2].x - srcPoints[1].x) + dstPoints[1].y * (srcPoints[0].x - srcPoints[2].x) + dstPoints[2].y * (srcPoints[1].x - srcPoints[0].x)) / det)
        
        transformationMatrix[5] = Double((dstPoints[0].y * (srcPoints[1].x * srcPoints[2].y - srcPoints[2].x * srcPoints[1].y) + dstPoints[1].y * (srcPoints[2].x * srcPoints[0].y - srcPoints[0].x * srcPoints[2].y) + dstPoints[2].y * (srcPoints[0].x * srcPoints[1].y - srcPoints[1].x * srcPoints[0].y)) / det)
        
        return transformationMatrix
    }
    
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
    
    static func applyAffineTransformation(_ image: UIImage?, points: [CGPoint]?) -> UIImage? {
        guard let cgImage = image?.cgImage, let points = points else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var srcPoints = [CGPoint](repeating: CGPoint(x: 0, y: 0), count: 3)
        var dstPoints = [CGPoint](repeating: CGPoint(x: 0, y: 0), count: 3)
        
        srcPoints[0] = points[0]
        srcPoints[1] = points[1]
        srcPoints[2] = points[2]
        
        dstPoints[0] = points[3]
        dstPoints[1] = points[4]
        dstPoints[2] = points[5]
        
        let transformationMatrix = getTransformationMatrix(srcPoints: srcPoints, dstPoints: dstPoints)
        
        var topLeft = CGPoint(x: Int(transformationMatrix[2]), y: Int(transformationMatrix[5]))
        var topRight = CGPoint(x: Int(transformationMatrix[0] * Double(width - 1) + transformationMatrix[2]), y: Int(transformationMatrix[3] * Double(width - 1) + transformationMatrix[5]))
        var bottomLeft = CGPoint(x: Int(transformationMatrix[1] * Double(height - 1) + transformationMatrix[2]), y: Int(transformationMatrix[4] * Double(height - 1) + transformationMatrix[5]))
        var bottomRight = CGPoint(x: Int(transformationMatrix[0] * Double(width - 1) + transformationMatrix[1] * Double(height - 1) + transformationMatrix[2]), y: Int(transformationMatrix[3] * Double(width - 1) + transformationMatrix[4] * Double(height - 1) + transformationMatrix[5]))
        
        let minX = Int(min(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x))
        let minY = Int(min(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y))
        
        topLeft = CGPoint(x: Int(transformationMatrix[2]), y: Int(transformationMatrix[5]))
        topRight = CGPoint(x: Int(transformationMatrix[0] * Double(width) + transformationMatrix[2]), y: Int(transformationMatrix[3] * Double(width) + transformationMatrix[5]))
        bottomLeft = CGPoint(x: Int(transformationMatrix[1] * Double(height) + transformationMatrix[2]), y: Int(transformationMatrix[4] * Double(height) + transformationMatrix[5]))
        bottomRight = CGPoint(x: Int(transformationMatrix[0] * Double(width) + transformationMatrix[1] * Double(height) + transformationMatrix[2]), y: Int(transformationMatrix[3] * Double(width) + transformationMatrix[4] * Double(height) + transformationMatrix[5]))
        
        let minWidthVal = min(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x)
        let minHeightVal = min(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y)
        let maxWidthVal = max(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x)
        let maxHeightVal = max(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y)
        
        let newWidth = abs(Int(maxWidthVal - minWidthVal))
        let newHeight = abs(Int(maxHeightVal - minHeightVal))
        
        let scale: Double = Double(max((Double(newWidth) / Double(width)), (Double(newHeight) / Double(height))))
        
        var transformedPixelData = [UInt8](repeating: 0, count: newWidth * newHeight * 4)
        
        let det = transformationMatrix[0] * transformationMatrix[4] - transformationMatrix[1] * transformationMatrix[3]
        
        DispatchQueue.concurrentPerform(iterations: newHeight) { y in
            for x in 0..<newWidth {
                let newIndex = (x + y * newWidth) * 4
                
                let part1 = transformationMatrix[4] * Double(x + minX)
                let part2 = transformationMatrix[1] * Double(y + minY)
                let part3 = transformationMatrix[1] * transformationMatrix[5] - transformationMatrix[2] * transformationMatrix[4]
                
                let oldX: Double = (part1 - part2 + part3) / det
                
                let part4 = transformationMatrix[3] * Double(x + minX)
                let part5 = transformationMatrix[0] * Double(y + minY)
                let part6 = transformationMatrix[2] * transformationMatrix[3] - transformationMatrix[0] * transformationMatrix[5]
                
                let oldY: Double = (-part4 + part5 + part6) / det
                
                if oldX < 0 || oldY < 0 || oldX >= Double(width) || oldY >= Double(height) {
                    continue
                }

                for c in 0..<4 {
                    if scale > 1 {
                        transformedPixelData[newIndex + c] = bilinearInterpolate(pixelData: pixelData, width: width, height: height, x: oldX, y: oldY, c: c)
                    } else {
                        transformedPixelData[newIndex + c] = trilinearInterpolate(pixelData1: pixelData, pixelData2: pixelData, width: width, height: height, x: oldX, y: oldY, mip: CGFloat(scale), c: c)
                    }
                }
            }
        }
        
        guard let transformedContext = CGContext(data: &transformedPixelData, width: newWidth, height: newHeight, bitsPerComponent: 8, bytesPerRow: newWidth * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let transformedImage = transformedContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: transformedImage)
    }
}
