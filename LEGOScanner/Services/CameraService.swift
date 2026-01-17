//
//  CameraService.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import AVFoundation
import UIKit

class CameraService: NSObject, ObservableObject {
    
    @Published var capturedImage: UIImage?
    @Published var isAuthorized = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    let session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    override init() {
        super.init()
        checkAuthorization()
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                isAuthorized = true
                setupCamera()
            case .notDetermined:
                requestAuthorization()
            case .denied, .restricted:
                isAuthorized = false
                alertMessage = "Camera access is required to scan LEGO pieces"
                showAlert = true
        @unknown default:
            break
        }
    }
    
    private func requestAuthorization() {
        AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.setupCamera()
                } else {
                    self?.alertMessage = "Camera access is required to scan LEGO pieces"
                    self?.showAlert = true
                }
            }
        }
    }
    
    private func setupCamera() {
        sessionQueue.async {[weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // Add video input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),                  self.session.canAddInput(videoDeviceInput) else {
                return
            }
            
            self.session.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            // Add photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
            }
            self.session.commitConfiguration()
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async {[weak self] in
            guard let self = self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Error saving file with name \(filename): \(error)")
            return nil
        }
    }
    
    func loadImageFromDocuments(_ filename: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}

