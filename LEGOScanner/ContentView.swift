//
//  ContentView.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/12/26.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Search Tab
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            // Scan Tab (Center)
            CameraScanView()
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }
                .tag(2)
            
            // Statistics Tab
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .accentColor(.red)
    }
}

// MARK: - Camera Scan View (Simplified wrapper)
struct CameraScanView: View {
    @State private var showCamera = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 100))
                    .foregroundColor(.red.opacity(0.6))
                
                Text("Scan LEGO Pieces")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Point your camera at LEGO pieces to automatically identify and catalog them")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    showCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Start Scanning")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 250)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(15)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Scan")
            .sheet(isPresented: $showCamera) {
                CameraView()
            }
        }
    }
}

// MARK: - Statistics View
struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total Pieces",
                            value: "\(viewModel.totalPieces)",
                            icon: "cube.box.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Unique Parts",
                            value: "\(viewModel.uniqueParts)",
                            icon: "square.stack.3d.up.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Categories",
                            value: "\(viewModel.categoryCount)",
                            icon: "folder.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Colors",
                            value: "\(viewModel.colorCount)",
                            icon: "paintpalette.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Category Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("By Category")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.categoryBreakdown, id: \.category) { item in
                            CategoryRow(
                                category: item.category,
                                count: item.count,
                                percentage: item.percentage
                            )
                        }
                    }
                    .padding(.top)
                    
                    // Color Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("By Color")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.colorBreakdown, id: \.color) { item in
                            ColorRow(
                                color: item.color,
                                count: item.count,
                                percentage: item.percentage
                            )
                        }
                    }
                    .padding(.top)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Scans")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.recentScans.isEmpty {
                            Text("No recent scans")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(viewModel.recentScans.prefix(5)) { scan in
                                RecentScanRow(scan: scan)
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("autoSaveLocation") private var autoSaveLocation = true
    @AppStorage("showConfidenceScores") private var showConfidenceScores = true
    @AppStorage("defaultSortOption") private var defaultSortOption = "dateAdded"
    
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var showDeleteConfirmation = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            List {
                // Statistics Section
                Section("Collection Overview") {
                    HStack {
                        Label("Total Pieces", systemImage: "cube.box.fill")
                        Spacer()
                        Text("\(CoreDataManager.shared.getStatistics().totalPieces)")
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Label("Unique Parts", systemImage: "square.stack.3d.up.fill")
                        Spacer()
                        Text("\(CoreDataManager.shared.getStatistics().uniqueParts)")
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Label("Categories", systemImage: "folder.fill")
                        Spacer()
                        Text("\(CoreDataManager.shared.getStatistics().categories)")
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                }
                
                // Export Section
                Section {
                    Button(action: {
                        showExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Export Collection")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Text("Export your LEGO collection to CSV, JSON, or Rebrickable XML format")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Data Management")
                }
                
                // Import Section
                Section {
                    Button(action: {
                        showImportPicker = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            Text("Import Collection")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Text("Import from previously exported JSON file")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Scanning Settings
                Section {
                    Toggle(isOn: $showConfidenceScores) {
                        HStack {
                            Image(systemName: "percent")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            Text("Show Confidence Scores")
                        }
                    }
                    
                    Toggle(isOn: $autoSaveLocation) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Auto-save Location")
                        }
                    }
                    
                    Toggle(isOn: $enableHaptics) {
                        HStack {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                            Text("Haptic Feedback")
                        }
                    }
                } header: {
                    Text("Scanning Preferences")
                } footer: {
                    Text("Confidence scores show how certain the AI is about piece identification")
                }
                
                // Default Sort
                Section {
                    Picker("Default Sort", selection: $defaultSortOption) {
                        Text("Date Added").tag("dateAdded")
                        Text("Part Number").tag("partNumber")
                        Text("Part Name").tag("partName")
                        Text("Color").tag("color")
                        Text("Quantity").tag("quantity")
                    }
                } header: {
                    Text("Display")
                }
                
                // Danger Zone
                Section {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            Text("Delete All Data")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("This will permanently delete all scanned LEGO pieces. This action cannot be undone.")
                }
                
                // About Section
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://rebrickable.com")!) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Powered by Rebrickable")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://github.com/yourusername/legoscanner")!) {
                        HStack {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            Text("Source Code")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        shareApp()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            Text("Share App")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("About")
                }
                
                // Credits
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LEGO Scanner")
                            .font(.headline)
                        Text("An AI-powered LEGO piece identification and cataloging app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("Made with ❤️ using SwiftUI, Core ML, and Vision")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
//            .confirmationDialog("Export Format", isPresented: $showExportSheet) {
//                Button("CSV") {
//                    exportToFormat(.csv)
//                }
//                Button("JSON") {
//                    exportToFormat(.json)
//                }
//                Button("Rebrickable XML") {
//                    exportToFormat(.xml)
//                }
//                Button("Cancel", role: .cancel) {}
//            } message: {
//                Text("Choose export format for your collection")
//            }
//            .sheet(isPresented: $showShareSheet) {
//                if let url = exportURL {
//                    ShareSheet(items: [url])
//                }
//            }
//            .fileImporter(
//                isPresented: $showImportPicker,
//                allowedContentTypes: [.json],
//                allowsMultipleSelection: false
//            ) { result in
//                handleImport(result: result)
//            }
            .alert("Delete All Data", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all \(CoreDataManager.shared.getStatistics().uniqueParts) scanned LEGO pieces. This action cannot be undone.")
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            
                            Text("Processing...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(30)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                }
            }
        }
    }
    
    // MARK: - Export Functions
    
//    private func exportToFormat(_ format: ExportFormat) {
//        isLoading = true
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let url: URL?
//            
//            switch format {
//            case .csv:
//                url = ExportService.shared.exportToCSV()
//            case .json:
//                url = ExportService.shared.exportToJSON()
//            case .xml:
//                url = ExportService.shared.exportToRebrickableXML()
//            }
//            
//            DispatchQueue.main.async {
//                isLoading = false
//                
//                if let url = url {
//                    exportURL = url
//                    showShareSheet = true
//                } else {
//                    alertMessage = "Export failed. Please try again."
//                    showSuccessAlert = true
//                }
//            }
//        }
//    }
    
    // MARK: - Import Function
    
//    private func handleImport(result: Result<[URL], Error>) {
//        switch result {
//        case .success(let urls):
//            guard let url = urls.first else { return }
//            
//            isLoading = true
//            
//            DispatchQueue.global(qos: .userInitiated).async {
//                let importResult = ExportService.shared.importFromJSON(url: url)
//                
//                DispatchQueue.main.async {
//                    isLoading = false
//                    
//                    switch importResult {
//                    case .success(let count):
//                        alertMessage = "Successfully imported \(count) piece\(count != 1 ? "s" : "")"
//                        showSuccessAlert = true
//                    case .failure(let error):
//                        alertMessage = "Import failed: \(error.localizedDescription)"
//                        showSuccessAlert = true
//                    }
//                }
//            }
//            
//        case .failure(let error):
//            alertMessage = "Failed to select file: \(error.localizedDescription)"
//            showSuccessAlert = true
//        }
//    }
    
    // MARK: - Delete Function
    
    private func deleteAllData() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let pieces = CoreDataManager.shared.fetchAllPieces()
            
            for piece in pieces {
                CoreDataManager.shared.deletePiece(piece)
            }
            
            DispatchQueue.main.async {
                isLoading = false
                alertMessage = "All data has been deleted"
                showSuccessAlert = true
            }
        }
    }
    
    // MARK: - Share Function
    
    private func shareApp() {
        let text = "Check out LEGO Scanner - an AI-powered app to identify and catalog your LEGO pieces!"
        let items: [Any] = [text]
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Export Format Enum

enum ExportFormat {
    case csv
    case json
    case xml
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryRow: View {
    let category: String
    let count: Int
    let percentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .font(.headline)
                Spacer()
                Text("\(count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ColorRow: View {
    let color: String
    let count: Int
    let percentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(colorFromName(color))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text(color)
                        .font(.headline)
                }
                
                Spacer()
                
                Text("\(count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(colorFromName(color))
                        .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
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
            "Dark Gray": Color(.darkGray),
        ]
        return colorMap[name] ?? .gray
    }
}

struct RecentScanRow: View {
    let scan: RecentScan
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.partName)
                    .font(.headline)
                
                Text(scan.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("×\(scan.quantity)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Statistics ViewModel

class StatisticsViewModel: ObservableObject {
    @Published var totalPieces: Int = 0
    @Published var uniqueParts: Int = 0
    @Published var categoryCount: Int = 0
    @Published var colorCount: Int = 0
    @Published var categoryBreakdown: [CategoryBreakdown] = []
    @Published var colorBreakdown: [ColorBreakdown] = []
    @Published var recentScans: [RecentScan] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        let pieces = CoreDataManager.shared.fetchAllPieces()
        
        // Basic stats
        totalPieces = pieces.reduce(0) { $0 + Int($1.quantity) }
        uniqueParts = pieces.count
        
        // Categories
        let categories = Dictionary(grouping: pieces) { $0.category ?? "Unknown" }
        categoryCount = categories.count
        
        categoryBreakdown = categories.map { category, items in
            let count = items.reduce(0) { $0 + Int($1.quantity) }
            return CategoryBreakdown(
                category: category,
                count: count,
                percentage: totalPieces > 0 ? Double(count) / Double(totalPieces) * 100 : 0
            )
        }.sorted { $0.count > $1.count }
        
        // Colors
        let colors = Dictionary(grouping: pieces) { $0.color ?? "Unknown" }
        colorCount = colors.count
        
        colorBreakdown = colors.map { color, items in
            let count = items.reduce(0) { $0 + Int($1.quantity) }
            return ColorBreakdown(
                color: color,
                count: count,
                percentage: totalPieces > 0 ? Double(count) / Double(totalPieces) * 100 : 0
            )
        }.sorted { $0.count > $1.count }
        
        // Recent scans
        recentScans = pieces.prefix(10).map { piece in
            RecentScan(
                id: piece.id ?? UUID(),
                partName: piece.partName ?? "",
                quantity: Int(piece.quantity),
                date: piece.dateAdded ?? Date()
            )
        }
    }
    
    func refresh() {
        loadData()
    }
}

// MARK: - Supporting Models

struct CategoryBreakdown: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
    let percentage: Double
}

struct ColorBreakdown: Identifiable {
    let id = UUID()
    let color: String
    let count: Int
    let percentage: Double
}

struct RecentScan: Identifiable {
    let id: UUID
    let partName: String
    let quantity: Int
    let date: Date
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
    }
}
