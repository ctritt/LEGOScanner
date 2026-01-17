//
//  ResultsView.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import SwiftUI
struct ResultsView: View {
    let scanResult: ScanResult
    @ObservedObject var viewModel: CameraViewModel
    @Environment(\.dismiss) var dismiss
    @State private var quantities: [UUID: Int] = [:]
    @State private var locations: [UUID: String] = [:]
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Original image with bounding boxes
                    ZStack {
                        Image(uiImage: scanResult.originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                        // Draw bounding boxes
                        GeometryReader { geometry in
                            ForEach(scanResult.detectedPieces) { piece in
                                Rectangle()
                                    .stroke(Color.green, lineWidth: 2)
                                    .frame(
                                        width: piece.boundingBox.width * geometry.size.width,
                                        height: piece.boundingBox.height * geometry.size.height
                                    )
                                    .position(
                                        x: piece.boundingBox.midX * geometry.size.width,
                                        y: piece.boundingBox.midY * geometry.size.height
                                    )
                            }
                        }
                    }
                    .padding()
                    // Results summary
                    Text("\(scanResult.detectedPieces.count) piece\(scanResult.detectedPieces.count != 1 ? "s" : "") detected")
                        .font(.title3)
                        .fontWeight(.semibold)
                    // Detected pieces list
                    VStack(spacing: 16) {
                        ForEach(scanResult.detectedPieces) { piece in
                            DetectedPieceRow(
                                piece: piece,
                                quantity: Binding(
                                    get: { quantities[piece.id] ?? 1 },
                                    set: { quantities[piece.id] = $0 }
                                ),
                                location: Binding(
                                    get: { locations[piece.id] ?? "" },
                                    set: { locations[piece.id] = $0 }
                                )
                            )
                        }
                    }
                    .padding()
                    // Save button
                    Button(action: {
                        saveAllPieces()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save All to Collection")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Scan Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $showingSaveConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("\(scanResult.detectedPieces.count) piece\(scanResult.detectedPieces.count != 1 ? "s" : "") saved to your collection")
            }
        }
    }
    
    private func saveAllPieces() {
        viewModel.saveAllPieces(quantities: quantities, locations: locations)
        showingSaveConfirmation = true
    }
}

struct DetectedPieceRow: View {
    let piece: DetectedPiece
    
    @Binding var quantity: Int
    @Binding var location: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Main row
            HStack(spacing: 12) {
                // Thumbnail
                if let image = piece.croppedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(piece.partName)
                        .font(.headline)
                    Text("Part #\(piece.partNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Text(piece.color)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f%% confident", piece.confidence * 100))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            // Expanded details
            if isExpanded {
                VStack(spacing: 12) {
                    Divider()
                    // Quantity stepper
                    HStack {
                        Text("Quantity:")
                            .font(.subheadline)
                        Spacer()
                        HStack(spacing: 16) {
                            Button(action: {
                                if quantity > 1 {
                                    quantity -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(quantity > 1 ? .red : .gray)
                            }
                            .disabled(quantity <= 1)
                            Text("\(quantity)")
                                .font(.headline)
                                .frame(minWidth: 30)
                            Button(action: {
                                quantity += 1
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    // Location input
                    HStack {
                        Text("Location:")
                            .font(.subheadline)
                        TextField("e.g., Box 1, Shelf A", text: $location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
