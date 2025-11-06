//
//  CameraManager.swift
//  TestHaptic
//
//  Created by Maksim Ponomarev on 11/5/25.
//

import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = true
    @Published var isSessionRunning = false
    
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var movieOutputRef: AVCaptureMovieFileOutput?
    
    override init() {
        super.init()
        debugPrint("CameraManager initialized")
    }
    
    func configure(with movieOutput: AVCaptureMovieFileOutput) {
        debugPrint("Configuring CameraManager with movie output")
        movieOutputRef = movieOutput
        checkAuthorization(movieOutput: movieOutput)
    }
    
    func checkAuthorization(movieOutput: AVCaptureMovieFileOutput? = nil) {
        debugPrint("Checking camera authorization")
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            debugPrint("Camera access already authorized")
            isAuthorized = true
            setupSession(movieOutput: movieOutput)
        case .notDetermined:
            debugPrint("Requesting camera access")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                debugPrint("Camera access granted: \(granted)")
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupSession(movieOutput: movieOutput)
                    }
                }
            }
        case .denied, .restricted:
            debugPrint("Camera access denied or restricted")
            isAuthorized = false
        @unknown default:
            debugPrint("Unknown authorization status")
            isAuthorized = false
        }
    }
    
    func setupSession(movieOutput: AVCaptureMovieFileOutput? = nil) {
        debugPrint("Setting up camera session")
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            
            // Add video input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                debugPrint("Failed to get video device")
                self.session.commitConfiguration()
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    debugPrint("Video input added successfully")
                } else {
                    debugPrint("Cannot add video input to session")
                    self.session.commitConfiguration()
                    return
                }
            } catch {
                debugPrint("Error creating video input: \(error.localizedDescription)")
                self.session.commitConfiguration()
                return
            }
            
            // Add audio input for video recording
            if let audioDevice = AVCaptureDevice.default(for: .audio) {
                do {
                    let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                    if self.session.canAddInput(audioInput) {
                        self.session.addInput(audioInput)
                        debugPrint("Audio input added successfully")
                    } else {
                        debugPrint("Cannot add audio input to session")
                    }
                } catch {
                    debugPrint("Error creating audio input: \(error.localizedDescription)")
                }
            } else {
                debugPrint("No audio device available")
            }
            
            // Add video output
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
                debugPrint("Video output added successfully")
            } else {
                debugPrint("Cannot add video output to session")
            }
            
            // Add movie file output for recording
            if let movieOutput = movieOutput {
                if self.session.canAddOutput(movieOutput) {
                    self.session.addOutput(movieOutput)
                    debugPrint("Movie output added successfully")
                } else {
                    debugPrint("Cannot add movie output to session")
                }
            }
            
            self.session.commitConfiguration()
            debugPrint("Camera session configured")
        }
    }
    
    func startSession() {
        debugPrint("Starting camera session")
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if !self.session.isRunning {
                self.session.startRunning()
                debugPrint("Camera session started")
                
                DispatchQueue.main.async {
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    func stopSession() {
        debugPrint("Stopping camera session")
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.session.isRunning {
                self.session.stopRunning()
                debugPrint("Camera session stopped")
                
                DispatchQueue.main.async {
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
}

