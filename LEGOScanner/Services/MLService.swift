import Foundation
import Vision
import CoreML
import UIKit

class MLService {
    
    static let shared = MLService()
    
    private var model: VNCoreMLModel?
    private let rebrickableAPI = RebrickableAPI.shared
    
    private init() {
        setupModel()
    }
    
    private func setupModel() {
        // For now, we'll use Vision's built-in object detection
        // Later replace with custom Core ML model
        // guard let model = try? VNCoreMLModel(for: LEGOClassifier().model) else {
        //     print("Failed to load Core ML model")
        //     return
        // }
        // self.model = model
    }
    
    func detectLegoPieces(in image: UIImage, completion: @escaping (Result<ScanResult, Error>) -> Void) {
        
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "MLService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Image"])))
            return
        }
        
        // Use Vision framework for object detection
        let request = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        guard let observations = request.results else {
            completion(.failure(NSError(domain: "MLService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No objects detected"])))
            return
        }
        
        // Process detected rectangles
        self.processDetections(observations, in: image, cgImage: cgImage, completion: completion)
        
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 3.0
        request.minimumSize = 0.1
        request.maximumObservations = 20
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func processDetections(_ observations: [VNRectangleObservation], in originalImage: UIImage, cgImage: CGImage, completion: @escaping (Result<ScanResult, Error>) -> Void) {
        
        var detectedPieces: [DetectedPiece] = []
        
        let group = DispatchGroup()
        
        for observation in observations {
            
            group.enter()
            
            // Convert normalized coordinates to image coordinates
            let boundingBox = VNImageRectForNormalizedRect(observation.boundingBox, cgImage.width, cgImage.height)
            
            // Crop the detected region
            if let croppedImage = cropImage(cgImage, to: boundingBox) {
                let uiImage = UIImage(cgImage: croppedImage)
                
                // Classify the cropped piece
                classifyPiece(image: uiImage) { result in
                    if case .success(let pieceInfo) = result {
                        let normalizedBox = CGRect(
                            x: observation.boundingBox.minX,
                            y: observation.boundingBox.minY,
                            width: observation.boundingBox.width,
                            height: observation.boundingBox.height)
                        
                        let detectedPiece = DetectedPiece(
                            partNumber: pieceInfo.partNumber,
                            partName: pieceInfo.partName,
                            color: pieceInfo.color,
                            colorId: pieceInfo.colorId,
                            category: pieceInfo.category,
                            confidence: pieceInfo.confidence,
                            boundingBox: normalizedBox,
                            croppedImage: uiImage
                        )
                        detectedPieces.append(detectedPiece)
                    }
                    group.leave()
                }
            }
            group .notify(queue: .main) {
                let scanResult = ScanResult(originalImage: originalImage, detectedPieces: detectedPieces, timestamp: Date())
                completion(.success(scanResult))
            }
        }
    }
    
    // MARK: - Image Processing
    private func cropImage(_ image: CGImage, to rect: CGRect) -> CGImage? {
        return image.cropping(to: rect)
    }
    
    // MARK: - Classification
    private func classifyPiece(image: UIImage, completion: @escaping (Result<PieceInfo, Error>) -> Void) {
        // For MVP: Use mock data
        // TODO: Replace with actual Core ML classification
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockPieces = [
                PieceInfo(
                    partNumber: "3001",
                    partName: "Brick 2x4",
                    color: "Red",
                    colorId: 5,
                    category: "Bricks",
                    confidence: 0.92
                ),
                PieceInfo(
                    partNumber: "3003",
                    partName: "Brick 2x2",
                    color: "Blue",
                    colorId: 7,
                    category: "Bricks",
                    confidence: 0.88
                ),
                PieceInfo(
                    partNumber: "3004",
                    partName: "Brick 1x2",
                    color: "Yellow",
                    colorId: 14,
                    category: "Bricks",
                    confidence: 0.85
                ),
                PieceInfo(
                    partNumber: "3020",
                    partName: "Plate 2x4",
                    color: "Green",
                    colorId: 10,
                    category: "Plates",
                    confidence: 0.90
                )
            ]
            
            let randomPiece = mockPieces.randomElement()!
            completion(.success(randomPiece))
        }
    }
    
    // MARK: - Core ML Classification (for when model is ready)
    
    private func classifyWithCoreML(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let model = model else {
            completion(.failure(NSError(domain: "MLService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])))
            return
        }
        
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "MLService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid Image"])))
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        guard let results = request.results as? [VNClassificationObservation],
        let topResult = results.first else {
            completion(.failure(NSError(domain: "MLService", code: -5, userInfo: [NSLocalizedDescriptionKey: "No classification results"])))
            return
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
}

struct PieceInfo {
    let partNumber: String
    let partName: String
    let color: String
    let colorId: Int16
    let category: String
    let confidence: Double
}
