//
//  SearchViewModel.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var pieces: [LegoPieceData] = []
    @Published var filteredPieces: [LegoPieceData] = []
    @Published var selectedCategory = "All"
    @Published var selectedColor = "All"
    @Published var sortOption = SortOption.dateAdded
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Recent"
        case nameAZ = "Name A-Z"
        case nameZA = "Name Z-A"
        case quantityHigh = "Quantity High-Low"
        case quantityLow = "Quantity Low-High"
    }
    
    var categories: [String] {
        let cats = Set(pieces.compactMap { $0.category })
        return ["All"] + cats.sorted()
    }
    
    var colors: [String] {
        let cols = Set(pieces.map { $0.color })
        return ["All"] + cols.sorted()
    }
    
    init() {
        loadPieces()
        setupSearchSubscription()
    }
    
    private func setupSearchSubscription() {
        Publishers.CombineLatest4(
            $searchText,
            $selectedCategory,
            $selectedColor,
            $sortOption
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink {[weak self] _ in
            self?.applyFilters()
        }.store(in: &cancellables)
    }
    
    func loadPieces() {
        let fetchedPieces = coreDataManager.fetchAllPieces()
        pieces = fetchedPieces.map {LegoPieceData(from: $0)}
        applyFilters()
    }
    
    private func applyFilters() {
        var filtered = pieces
        
        // Text search
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.partName.localizedCaseInsensitiveContains(searchText) || $0.partNumber.localizedCaseInsensitiveContains(searchText) || $0.color.localizedCaseInsensitiveContains(searchText) || ($0.location?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Category filter
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Color filter
        if selectedColor != "All" {
            filtered = filtered.filter { $0.color == selectedColor }
        }
        
        // Sort
        switch sortOption {
        case .dateAdded:
            filtered.sort { $0.dateAdded > $1.dateAdded }
        case .nameAZ:
            filtered.sort { $0.partName < $1.partName }
        case .nameZA:
            filtered.sort { $0.partName > $1.partName }
        case .quantityHigh:
            filtered.sort { $0.quantity > $1.quantity }
        case .quantityLow:
            filtered.sort { $0.quantity < $1.quantity }
        }
        
        filteredPieces = filtered
    }
    
    func resetFilters() {
        searchText = ""
        selectedCategory = "All"
        selectedColor = "All"
        sortOption = .dateAdded
    }
}
