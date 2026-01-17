//
//  PieceDetailView.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import SwiftUI

struct PieceDetailView: View {
    let piece: LegoPieceData
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Image
                    if let imagePath = piece.imagePath,
                       let image = CameraService().loadImageFromDocuments(imagePath) {                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 10)
                    }
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text(piece.partName)
                            .font(.title)
                            .fontWeight(.bold)
                        DetailRow(label: "Part Number", value: piece.partNumber)
                        DetailRow(label: "Color", value: piece.color)
                        DetailRow(label: "Quantity", value: "\(piece.quantity)")
                        if let category = piece.category {
                            DetailRow(label: "Category", value: category)
                        }
                        if let location = piece.location {
                            DetailRow(label: "Location", value: location)
                        }
                        if let confidence = piece.confidence {
                            DetailRow(
                                label: "Confidence",
                                value: String(format: "%.1f%%", confidence * 100)
                            )
                        }
                        DetailRow(
                            label: "Date Added",
                            value: piece.dateAdded.formatted(date: .abbreviated, time: .shortened)                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Piece Details")
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

struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
