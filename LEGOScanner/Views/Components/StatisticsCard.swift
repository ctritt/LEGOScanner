//
//  StatisticsCard.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import SwiftUI

struct StatisticsCard: View {
    let totalPieces: Int
    let uniqueParts: Int
    let categories: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Collection")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            HStack(spacing: 20) {
                StatItem(value: "\(totalPieces)", label: "Total Pieces")
                StatItem(value: "\(uniqueParts)", label: "Unique Parts")
                StatItem(value: "\(categories)", label: "Categories")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.red, Color.red.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
