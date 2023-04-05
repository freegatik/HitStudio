//
//  RotateModel.swift
//  HitStudio
//
//  Created by freegatik on 23.03.2023.
//

import SwiftUI
import CoreGraphics

enum RotateModel {
    static func rotateImage(_ image: UIImage?, byAngle angle: Int?) -> UIImage? {
        guard let cgImage = image?.cgImage, let angle = angle else {
            return image
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let radians = Double(angle) * .pi / 180.0
        
        let rotatedWidth = Int(abs(CGFloat(width) * cos(radians)) + abs(CGFloat(height) * sin(radians)))
        let rotatedHeight = Int(abs(CGFloat(width) * sin(radians)) + abs(CGFloat(height) * cos(radians)))
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var rotatedPixelData = [UInt8](repeating: 0, count: rotatedWidth * rotatedHeight * 4)
        
        DispatchQueue.concurrentPerform(iterations: rotatedHeight) { y in
            rotateRow(y, width: width, height: height, radians: radians, rotatedWidth: rotatedWidth, rotatedHeight: rotatedHeight, pixelData: &pixelData, rotatedPixelData: &rotatedPixelData)
        }
        
        guard let rotatedContext = CGContext(data: &rotatedPixelData, width: rotatedWidth, height: rotatedHeight, bitsPerComponent: 8, bytesPerRow: 4 * rotatedWidth, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let rotatedImage = rotatedContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: rotatedImage)
    }
    
    private static func rotateRow(_ y: Int, width: Int, height: Int, radians: Double, rotatedWidth: Int, rotatedHeight: Int, pixelData: inout [UInt8], rotatedPixelData: inout [UInt8]) {
        for x in 0..<rotatedWidth {
            let sourceX = Int((CGFloat(x) - CGFloat(rotatedWidth) / 2) * cos(-radians) - (CGFloat(y) - CGFloat(rotatedHeight) / 2) * sin(-radians) + CGFloat(width) / 2)
            let sourceY = Int((CGFloat(x) - CGFloat(rotatedWidth) / 2) * sin(-radians) + (CGFloat(y) - CGFloat(rotatedHeight) / 2) * cos(-radians) + CGFloat(height) / 2)
            
            let sourceIndex = (sourceX + sourceY * width) * 4
            
            if sourceX >= 0 && sourceX < width && sourceY >= 0 && sourceY < height {
                let destinationIndex = (x + y * rotatedWidth) * 4
                
                rotatedPixelData[destinationIndex] = pixelData[sourceIndex]
                rotatedPixelData[destinationIndex + 1] = pixelData[sourceIndex + 1]
                rotatedPixelData[destinationIndex + 2] = pixelData[sourceIndex + 2]
                rotatedPixelData[destinationIndex + 3] = pixelData[sourceIndex + 3]
            }
        }
    }
}
