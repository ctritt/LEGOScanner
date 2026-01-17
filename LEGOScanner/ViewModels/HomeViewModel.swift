//
//  HomeViewModel.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import Foundation
import Combine
import CoreData

class HomeViewModel: ObservableObject {
    
    @Published var pieces: [LegoPieceData] = []
    @Published var totalPieces: Int = 0
    @Published var uniqueParts: Int = 0
    @Published var categoryCount: Int = 0
    @Published var isLoading = false
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadPieces()
        loadStatistics()
    }
    
    func loadPieces() {
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self else { return }
        }
        
        let fetchedPieces = self.coreDataManager.fetchAllPieces()
        let pieceData = fetchedPieces.map { LegoPieceData(from: $0) }
        
        DispatchQueue.main.async {
            self.pieces = pieceData
            self.isLoading = false
        }
    }
    
    func loadStatistics() {
        let stats = coreDataManager.getStatistics()
        totalPieces = stats.totalPieces
        uniqueParts = stats.uniqueParts
        categoryCount = stats.categories
    }
    
    func deletePiece(_ piece: LegoPieceData) {
        let request: NSFetchRequest<LegoPiece> = LegoPiece.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", piece.id as CVarArg)
        if let fetchedPiece = try? coreDataManager.context.fetch(request).first {            coreDataManager.deletePiece(fetchedPiece)
            loadPieces()
            loadStatistics()
        }
    }
    
    func refresh() {
        loadPieces()
        loadStatistics()
    }
}


