//
//  LegoPiece.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/12/26.
//

import Foundation
import CoreData

extension LegoPiece {
    
    static func create(in context: NSManagedObjectContext, partNumber: String, partName: String, color: String, colorId: Int16, quantity: Int16 = 1, imagePath: String? = nil, category: String? = nil, location: String? = nil, confidence: Double? = nil) -> LegoPiece {
        
        let piece = LegoPiece(context: context)
        piece.id = UUID()
        piece.partNumber = partNumber
        piece.partName = partName
        piece.color = color
        piece.colorId = colorId
        piece.quantity = quantity
        piece.imagePath = imagePath
        piece.category = category
        piece.location = location
        piece.confidence = confidence
        piece.dateAdded = Date()
        return piece
    }
}

struct LegoPieceData: Identifiable {
    let id: UUID
    let partNumber: String
    let partName: String
    let color: String
    let colorId: Int16
    let quantity: Int16
    let imagePath: String?
    let category: String?
    let location: String?
    let confidence: Double?
    let dateAdded: Date
    
    init(from piece: LegoPiece) {
        self.id = piece.id ?? UUID()
        self.partNumber = piece.partNumber ?? ""
        self.partName = piece.partName ?? ""
        self.color = piece.color ?? ""
        self.colorId = piece.colorId
        self.quantity = piece.quantity
        self.imagePath = piece.imagePath
        self.category = piece.category
        self.location = piece.location
        self.confidence = piece.confidence
        self.dateAdded = piece.dateAdded ?? Date()
    }
}
