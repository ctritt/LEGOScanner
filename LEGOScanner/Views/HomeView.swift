//
//  HomeView.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showCamera = false
    @State private var showSearch = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Statistics Card
                        StatisticsCard(
                            totalPieces: viewModel.totalPieces,
                            uniqueParts: viewModel.uniqueParts,
                            categories: viewModel.categoryCount
                        )
                        .padding(.horizontal)
                        // Recent Scans Header
                        HStack {
                            Text("Recent Scans")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            if !viewModel.pieces.isEmpty {
                                Button("View All") {
                                    showSearch = true
                                }
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        // Pieces List
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if viewModel.pieces.isEmpty {
                            EmptyStateView()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(viewModel.pieces.prefix(10))) { piece in
                                    PieceCard(piece: piece) {
                                        viewModel.deletePiece(piece)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    viewModel.refresh()
                }
                // Floating Action Button
                VStack {
                    Spacer()
                    Button(action: {
                        showCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Scan Pieces")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(30)
                        .shadow(radius: 5)
                    }
                    .padding(.bottom, 30)
                }            }
            .navigationTitle("LEGO Scanner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                    }                }            }
            .sheet(isPresented: $showCamera) {
                CameraView()
                    .onDisappear {
                        viewModel.refresh()
                    }            }
            .sheet(isPresented: $showSearch) {
                SearchView()
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            Text("No pieces scanned yet")
                .font(.title3)
                .foregroundColor(.gray)
            Text("Tap the camera button to start")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding()
    }
}

