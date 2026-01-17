//
//  PieceCard.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import SwiftUI

struct PieceCard: View {
    let piece: LegoPieceData
    let onDelete: () -> Void
    
    @State private var showDetails = false
    
    var body: some View {
        Button(action: {
            showDetails = true
        }) {
            HStack(spacing: 12) {
                // Image
                if let imagePath = piece.imagePath,
                   let image = CameraService().loadImageFromDocuments(imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "cube.box.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(piece.partName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text("Part #\(piece.partNumber)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        // Color indicator
                        HStack(spacing: 4) {
                            Circle()
                                .fill(colorFromName(piece.color))
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            Text(piece.color)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        // Quantity
                        HStack(spacing: 4) {
                            Image(systemName: "square.stack.3d.up.fill")
                                .font(.caption)
                            Text("×\(piece.quantity)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                    }
                    // Location if available
                    if let location = piece.location {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(location)
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                    }
                }
                Spacer()
                // Delete button
                Button(action: {
                    withAnimation {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.6))
                        .padding(8)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            PieceDetailView(piece: piece)
        }
    }
    
    private func colorFromName(_ name: String) -> Color {
        let colorMap: [String: Color] = [
            "Red": .red,
            "Blue": .blue,
            "Yellow": .yellow,
            "Green": .green,
            "Black": .black,
            "White": .white,
            "Orange": .orange,
            "Brown": .brown,
            "Pink": .pink,
            "Purple": .purple,
            "Lime": Color(red: 0.64, green: 0.76, blue: 0),
            "Tan": Color(red: 0.87, green: 0.78, blue: 0.61),
            "Light Gray": .gray,
            "Dark Gray": Color(.darkGray)
        ]
        return colorMap[name] ?? .gray
    }
}
