//
//  CameraViewModel.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import Foundation
import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    
    @Published var scanResult: ScanResult?
    @Published var isProcessing = false
    @Published var showResults = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let mlService = MLService.shared
    private let cameraService = CameraService()
    
    func processImage(_ image: UIImage) {
        isProcessing = true
        errorMessage = nil
        
        mlService.detectLegoPieces(in: image) {[weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                switch result {
                case .success(let scanResult):
                    self?.scanResult = scanResult
                    self?.showResults = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }
    
    func saveAllPieces(quantities: [UUID: Int], locations: [UUID: String]) {
        
        guard let scanResult else { return }
        
        for piece in scanResult.detectedPieces {
            let quantity = quantities[piece.id] ?? 1
            let location = locations[piece.id]
            
            // Save image
            var imagePath: String?
            if let croppedImage = piece.croppedImage {
                imagePath = cameraService.saveImageToDocuments(croppedImage)
            }
            
            CoreDataManager.shared.savePiece(
                partNumber: piece.partNumber,
                partName: piece.partName,
                color: piece.color,
                colorId: piece.colorId,
                quantity: Int16(quantity),
                imagePath: imagePath,
                category: piece.category,
                location: location,
                confidence: piece.confidence
            )
        }
    }
}

