//
//  EditImageViewModel.swift
//  HitStudio
//
//  Created by freegatik on 19.03.2023.
//

import SwiftUI
import Combine

class EditImageViewModel: ObservableObject {
    
    @Published var originalImage: UIImage? {
        didSet {
            editedImage = originalImage
        }
    }
    
    var originalImageData: Data? {
        didSet {
            if let imageData = originalImageData {
                originalImage = UIImage(data: imageData)
            }
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    @Published var editedImage: UIImage?
    @Published var nonChangedImage: UIImage?
    
    @Published var resizeSliderValue: Double?
    @Published var mosaicSliderValue: Int?
    @Published var rotateSliderValue: Int?
    @Published var thresholdSliderValue: Int?
    @Published var amountSliderValue: Int?
    @Published var radiusSliderValue: Int?
    
    @Published var brushSize: Double = 30
    @Published var retouchStrength: Double = 0.5
    
    @Published var affinePoints: [CGPoint] = []
    @Published var geometryPoints: [CGPoint] = []
    
    private var undoStack: [UIImage] = []
    private var redoStack: [UIImage] = []
    
    private let imageProcessingQueue = DispatchQueue(label: "imageProcessing", qos: .userInitiated, attributes: .concurrent)
    
    @Published var isProcessing = false
    
    private func addCurrentImageToChangeListArray() {
        if let currentImage = editedImage {
            undoStack.append(currentImage)
        }
    }
    
    func undo() {
        guard !undoStack.isEmpty else { return }
        if let lastImage = undoStack.popLast() {
            redoStack.append(editedImage ?? UIImage())
            originalImage = lastImage
            editedImage = lastImage
        }
    }
    
    func redo() {
        guard !redoStack.isEmpty else { return }
        if let redoImage = redoStack.popLast() {
            undoStack.append(editedImage ?? UIImage())
            originalImage = redoImage
            editedImage = redoImage
        }
    }
    
    func resetToOriginalImage() {
        originalImage = nonChangedImage
        editedImage = nonChangedImage
        undoStack.removeAll()
        redoStack.removeAll()
    }
    
    func rotateImage() {
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            let rotatedImage = RotateModel.rotateImage(self.originalImage, byAngle: self.rotateSliderValue)
            
            DispatchQueue.main.async {
                self.originalImage = rotatedImage
                self.editedImage = rotatedImage
                self.isProcessing = false
            }
        }
    }
    
    func resizeImage() {
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            let resizedImage = ResizeModel.resizeImage(self.originalImage, scale: self.resizeSliderValue)
            
            DispatchQueue.main.async {
                self.originalImage = resizedImage
                self.editedImage = resizedImage
                self.isProcessing = false
            }
        }
    }
    
    func applyNegativeFilter() {
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            let filteredImage = FiltersModel.applyNegativeFilter(self.originalImage)
            
            DispatchQueue.main.async {
                self.originalImage = filteredImage
                self.editedImage = filteredImage
                self.isProcessing = false
            }
        }
    }
    
    func applyMosaicFilter() {
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            let filteredImage = FiltersModel.applyMosaicFilter(self.originalImage, blockSize: self.mosaicSliderValue)
            
            DispatchQueue.main.async {
                self.originalImage = filteredImage
                self.editedImage = filteredImage
                self.isProcessing = false
            }
        }
    }
    
    func applyMedianFilter() {
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            let filteredImage = FiltersModel.applyMedianFilter(self.originalImage)
            
            DispatchQueue.main.async {
                self.originalImage = filteredImage
                self.editedImage = filteredImage
                self.isProcessing = false
            }
        }
    }
    
    func applyGaussianBlurFilter() {
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            let filteredImage = FiltersModel.applyGaussianBlurFilter(self.originalImage)
            
            DispatchQueue.main.async {
                self.originalImage = filteredImage
                self.editedImage = filteredImage
                self.isProcessing = false
            }
        }
    }
    
    func retouchImage(at point: CGPoint, in viewSize: CGSize) {
        guard let image = editedImage else { return }
        let imageSize = image.size
        let convertedPoint = convertPoint(point, fromViewSize: viewSize, toImageSize: imageSize)
        
        guard (0..<imageSize.width).contains(convertedPoint.x),
              (0..<imageSize.height).contains(convertedPoint.y) else {
            return
        }
        
        imageProcessingQueue.async {
            let filteredImage = RetouchModel.applyRetouchFilter(image, centerX: Int(convertedPoint.x), centerY: Int(convertedPoint.y), radius: Int(self.brushSize), retouchStrength: self.retouchStrength)
            
            DispatchQueue.main.async {
                self.editedImage = filteredImage
            }
        }
    }
    
    func convertPoint(_ point: CGPoint, fromViewSize viewSize: CGSize, toImageSize imageSize: CGSize) -> CGPoint {
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        
        let scale = min(scaleX, scaleY)
        
        let offsetX = (viewSize.width - imageSize.width * scale) / 2
        let offsetY = (viewSize.height - imageSize.height * scale) / 2
        
        let correctedX = (point.x - offsetX) / scale
        let correctedY = (point.y - offsetY) / scale
        
        return CGPoint(x: correctedX, y: correctedY)
    }
    
    func applyUnsharpMask() {
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            let maskedImage = UnsharpMaskModel.applyUnsharpMask(self.originalImage, threshold: self.thresholdSliderValue, amount: self.amountSliderValue, radius: self.radiusSliderValue)
            
            DispatchQueue.main.async {
                self.originalImage = maskedImage
                self.editedImage = maskedImage
                self.isProcessing = false
            }
        }
    }
    
    func convertPointAffine(_ point: CGPoint, fromViewSize viewSize: CGSize, toImageSize imageSize: CGSize) -> CGPoint {
            let scaleX = viewSize.width / imageSize.width
            let scaleY = viewSize.height / imageSize.height

            let scale = max(scaleX, scaleY)

            let offsetX = (viewSize.width - imageSize.width * scale) / 2
            let offsetY = (viewSize.height - imageSize.height * scale) / 2

            let correctedX = (point.x - offsetX) / scale
            let correctedY = (point.y - offsetY) / scale

            return CGPoint(x: correctedX, y: correctedY)
    }
    
    func addAffinePoint(at point: CGPoint, in viewSize: CGSize) {
            guard let image = editedImage else { return }
            let imageSize = image.size
            let convertedPoint = convertPointAffine(point, fromViewSize: viewSize, toImageSize: imageSize)
            affinePoints.append(convertedPoint)
    }
    
    func checkIfEquals(point: CGPoint) -> Bool {
            if affinePoints.count + 1 <= 3 {
                for i in 0..<affinePoints.count {
                    if point == affinePoints[i] { return true }
                }
            } else {
                for i in 3..<affinePoints.count {
                    if point == affinePoints[i] { return true }
                }
            }
            
            return false
    }
    
    func applyAffineTransformation() {
        if self.affinePoints.count != 6 { return }
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            let transformedImage = AffineTransformationModel.applyAffineTransformation(self.originalImage, points: self.affinePoints)
            self.affinePoints = []
            self.geometryPoints = []
            
            DispatchQueue.main.async {
                self.originalImage = transformedImage
                self.editedImage = transformedImage
                self.isProcessing = false
            }
        }
    }
    
    func detectFacesInImage() {
        isProcessing = true
        addCurrentImageToChangeListArray()
        
        imageProcessingQueue.async {
            FaceModel.detectFaces(in: self.originalImage!) { result in
                switch result {
                case .success(let facedImage):
                    DispatchQueue.main.async {
                        self.originalImage = facedImage
                        self.editedImage = facedImage
                        self.isProcessing = false
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Face detection error: \(error)")
                        self.isProcessing = false
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        window.rootViewController?.present(alert, animated: true)
    }
    
    func saveImage() {
        let image = editedImage ?? UIImage()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
