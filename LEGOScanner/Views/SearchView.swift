//
//  SearchView.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search by name, part #, color...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    Button(action: {
                        showFilterSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                // Active filters
                if viewModel.selectedCategory != "All" || viewModel.selectedColor != "All" || viewModel.sortOption != .dateAdded {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if viewModel.selectedCategory != "All" {
                                FilterChip(text: "Category: \(viewModel.selectedCategory)") {
                                    viewModel.selectedCategory = "All"
                                }
                            }
                            if viewModel.selectedColor != "All" {
                                FilterChip(text: "Color: \(viewModel.selectedColor)") {
                                    viewModel.selectedColor = "All"
                                }
                            }
                            if viewModel.sortOption != .dateAdded {
                                FilterChip(text: "Sort: \(viewModel.sortOption.rawValue)") {
                                    viewModel.sortOption = .dateAdded
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }
                // Results count
                HStack {
                    Text("\(viewModel.filteredPieces.count) piece\(viewModel.filteredPieces.count != 1 ? "s" : "") found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                // Results list
                if viewModel.filteredPieces.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No pieces found")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredPieces) { piece in
                                PieceCard(piece: piece) {
                                    // Delete action
                                    if let index = viewModel.pieces.firstIndex(where: { $0.id == piece.id }) {
                                        viewModel.pieces.remove(at: index)
                                        viewModel.loadPieces()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(viewModel: viewModel)
            }
        }
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.red.opacity(0.1))
        .foregroundColor(.red)
        .cornerRadius(16)
    }
}

struct FilterSheetView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Form {
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Section("Color") {
                    Picker("Color", selection: $viewModel.selectedColor) {
                        ForEach(viewModel.colors, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Section("Sort By") {
                    Picker("Sort", selection: $viewModel.sortOption) {
                        ForEach(SearchViewModel.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Section {
                    Button("Reset All Filters") {
                        viewModel.resetFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}



