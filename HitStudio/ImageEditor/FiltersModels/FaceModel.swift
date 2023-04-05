//
//  FaceModel.swift
//  HitStudio
//
//  Created by freegatik on 02.04.2023.
//

import SwiftUI
import Vision

enum FaceModel {
    enum DetectionError: Error {
        case invalidImage
        case requestFailed
    }
    
    static func detectFaces(in image: UIImage, completion: @escaping (Result<UIImage, DetectionError>) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            AppLogger.error("FaceModel: CIImage could not be created from UIImage.")
            completion(.failure(.invalidImage))
            return
        }
        
        let request = VNDetectFaceRectanglesRequest(completionHandler: { request, error in
            guard error == nil else {
                AppLogger.error("FaceModel: Vision request failed.")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let results = request.results as? [VNFaceObservation], !results.isEmpty else {
                completion(.success(image))
                return
            }
            
            var outputImage = image
            for face in results {
                outputImage = addRect(face, to: outputImage)
            }
            
            completion(.success(outputImage))
        })
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            AppLogger.error("FaceModel: handler.perform failed — \(error.localizedDescription)")
            completion(.failure(.requestFailed))
        }
    }
    
    private static func addRect(_ result: VNFaceObservation, to image: UIImage) -> UIImage {
        var image = image
        
        let imageSize = CGSize(width: image.size.width, height: image.size.height)
        let boundingBox = result.boundingBox
        let scaledBox = CGRect(
            x: boundingBox.origin.x * imageSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.size.height) * imageSize.height,
            width: boundingBox.size.width * imageSize.width,
            height: boundingBox.size.height * imageSize.height
        )
        
        let normalizedRect = VNNormalizedRectForImageRect(scaledBox, Int(imageSize.width), Int(imageSize.height))
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(10.0)
        context.stroke(CGRect(x: normalizedRect.origin.x * imageSize.width, y: normalizedRect.origin.y * imageSize.height, width: normalizedRect.size.width * imageSize.width, height: normalizedRect.size.height * imageSize.height))
        
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
