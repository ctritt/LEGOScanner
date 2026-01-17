//
//  CoreDataManager.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/12/26.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "LEGOScanner")
        persistentContainer.loadPersistentStores {
            description, error in if let error = error {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    func savePiece(
        partNumber: String,
        partName: String,
        color: String,
        colorId: Int16,
        quantity: Int16,
        imagePath: String?,
        category: String?,
        location: String?,
        confidence: Double?
    ) {
        let piece = LegoPiece.create(
            in: context,
            partNumber: partNumber,
            partName: partName,
            color: color,
            colorId: colorId,
            quantity: quantity,
            imagePath: imagePath,
            category: category,
            location: location,
            confidence: confidence)
        save()
    }
    
    func fetchAllPieces() -> [LegoPiece] {
        let request: NSFetchRequest<LegoPiece> = LegoPiece.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching pieces: \(error)")
            return []
        }
    }
    
    func searchPieces(query: String) -> [LegoPiece] {
        let request: NSFetchRequest<LegoPiece> = LegoPiece.fetchRequest()
        let predicate = NSPredicate(format: "partNumber CONTAINS[cd] %@ OR partName CONTAINS[cd] %@ OR color CONTAINS[cd] %@ OR location CONTAINS[cd] %@", query, query, query, query)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error searching pieces: \(error)")
            return []
        }
    }
    
    func deletePiece(_ piece: LegoPiece) {
        context.delete(piece)
        save()
    }
    
    func updatePiece(_ piece: LegoPiece, quantity: Int16?, location: String?) {
        if let quantity = quantity {
            piece.quantity = quantity
        }
        if let location = location {
            piece.location = location
        }
        save()
    }
    
    func getStatistics() -> (totalPieces: Int, uniqueParts: Int, categories: Int) {
        let pieces = fetchAllPieces()
        let totalPieces = pieces.reduce(0) { $0 + Int($1.quantity) }
        let uniqueParts = pieces.count
        let categories = Set(pieces.compactMap { $0.category }).count
        return (totalPieces, uniqueParts, categories)
    }
}
