//
//  CameraView.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showImagePicker = false
    @State private var showResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if cameraService.isAuthorized {
                    CameraPreviewView(session: cameraService.session)
                        .ignoresSafeArea()
                    VStack {
                        Spacer()
                        HStack(spacing: 40) {
                            // Gallery button
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            // Capture button
                            Button(action: {
                                cameraService.capturePhoto()
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .frame(width: 80, height: 80)
                                    )
                            }
                            // Placeholder for symmetry
                            Color.clear
                                .frame(width: 60, height: 60)
                        }
                        .padding(.bottom, 40)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Camera Access Required")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Please enable camera access in Settings to scan LEGO pieces")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                // Processing overlay
                if viewModel.isProcessing {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Analyzing LEGO pieces...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Scan Pieces")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                cameraService.startSession()
            }
            .onDisappear {
                cameraService.stopSession()
            }
            .onChange(of: cameraService.capturedImage) { image in
                if let image = image {
                    processImage(image)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: Binding(
                    get: { cameraService.capturedImage },
                    set: { newImage in
                        if let newImage = newImage {
                            cameraService.capturedImage = newImage
                        }
                    }
                ))
            }
            .sheet(isPresented: $viewModel.showResults) {
                if let scanResult = viewModel.scanResult {
                    ResultsView(
                        scanResult: scanResult,
                        viewModel: viewModel
                    )
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        viewModel.processImage(image)
    }
}

// Camera Preview
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}


