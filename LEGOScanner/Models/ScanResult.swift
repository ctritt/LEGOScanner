//
//  ScanResult.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/12/26.
//

import Foundation
import UIKit

struct DetectedPiece: Identifiable {
    let id = UUID()
    let partNumber: String
    let partName: String
    let color: String
    let colorId: Int16
    let category: String
    let confidence: Double
    let boundingBox: CGRect
    let croppedImage: UIImage?
}

struct ScanResult {
    let originalImage: UIImage
    let detectedPieces: [DetectedPiece]
    let timestamp: Date
}
