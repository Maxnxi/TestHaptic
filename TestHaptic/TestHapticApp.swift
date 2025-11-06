//
//  TestHapticApp.swift
//  TestHaptic
//
//  Created by Maksim Ponomarev on 11/5/25.
//

import SwiftUI
import AVFoundation

@main
struct TestHapticApp: App {
    init() {
        debugPrint("TestHapticApp initializing")
        setupAudioSession()
        disableIdleTimer()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupAudioSession() {
        debugPrint("Setting up AVAudioSession")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
				mode: .videoRecording,
                options: [
					.defaultToSpeaker,
					.allowBluetooth
				]
            )
            debugPrint("AVAudioSession category set successfully")
            
            try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
            debugPrint("Haptics and system sounds during recording enabled")
            
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("AVAudioSession activated")
        } catch {
            debugPrint("Error setting up AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    private func disableIdleTimer() {
        debugPrint("Disabling idle timer")
        UIApplication.shared.isIdleTimerDisabled = true
    }
}
