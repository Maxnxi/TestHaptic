//
//  VideoRecordingManager.swift
//  TestHaptic
//
//  Created by Maksim Ponomarev on 11/5/25.
//

import AVFoundation
import SwiftUI

class VideoRecordingManager: NSObject, ObservableObject {
    @Published var isRecording = false
    
    private let movieOutput = AVCaptureMovieFileOutput()
    private var outputURL: URL?
    
    override init() {
        super.init()
        debugPrint("VideoRecordingManager initialized")
    }
    
    func getMovieOutput() -> AVCaptureMovieFileOutput {
        debugPrint("Getting movie output")
        return movieOutput
    }
    
    func startRecording() {
        debugPrint("Starting video recording")
        
        guard !movieOutput.isRecording else {
            debugPrint("Already recording")
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "video_\(dateString).mov"
        outputURL = documentsPath.appendingPathComponent(fileName)
        
        debugPrint("Recording to: \(outputURL?.path ?? "unknown")")
        
        guard let url = outputURL else {
            debugPrint("Failed to create output URL")
            return
        }
        
        // Remove file if it exists
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                debugPrint("Removed existing file at path")
            } catch {
                debugPrint("Failed to remove existing file: \(error.localizedDescription)")
            }
        }
        
        movieOutput.startRecording(to: url, recordingDelegate: self)
        debugPrint("Movie output startRecording called")
    }
    
    func stopRecording() {
        debugPrint("Stopping video recording")
        
        guard movieOutput.isRecording else {
            debugPrint("Not currently recording")
            return
        }
        
        movieOutput.stopRecording()
        debugPrint("Movie output stopRecording called")
    }
}

extension VideoRecordingManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        debugPrint("Did start recording to: \(fileURL.path)")
        
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        debugPrint("Did finish recording to: \(outputFileURL.path)")
        
        if let error = error {
            debugPrint("Recording error: \(error.localizedDescription)")
        } else {
            debugPrint("Recording finished successfully")
            
            // Check file size
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: outputFileURL.path)
                if let fileSize = attributes[.size] as? Int64 {
                    debugPrint("Video file size: \(fileSize) bytes")
                }
            } catch {
                debugPrint("Failed to get file attributes: \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}

