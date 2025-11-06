//
//  HapticManager.swift
//  TestHaptic
//
//  Created by Maksim Ponomarev on 11/5/25.
//

import UIKit
import CoreHaptics
import SwiftUI
import AVFAudio

class HapticManager: ObservableObject {
    private var hapticEngine: CHHapticEngine?
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    init() {
        debugPrint("HapticManager initialized")
        setupHapticEngine()
        prepareImpactGenerator()
    }
    
    // MARK: - UIImpactFeedbackGenerator
    
    private func prepareImpactGenerator() {
//		try? AVAudioSession.sharedInstance().setActive(false)

        debugPrint("Preparing UIImpactFeedbackGenerator")
        impactGenerator.prepare()
		
		debugPrint("AVAudioSession category would reset")
//		try? AVAudioSession.sharedInstance().setCategory(
//			.multiRoute,
//			mode: .default,
//			options: [.defaultToSpeaker, .allowBluetooth]
//		)
//		try? AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
//		try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func triggerImpactFeedback() {
        debugPrint("Triggering UIImpactFeedbackGenerator")
        impactGenerator.impactOccurred()
        debugPrint("UIImpactFeedbackGenerator triggered")
    }
    
    // MARK: - CHHapticEngine
    
    private func setupHapticEngine() {
        debugPrint("Setting up CHHapticEngine")
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            debugPrint("Device does not support haptics")
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            debugPrint("CHHapticEngine started successfully")
            
            hapticEngine?.resetHandler = { [weak self] in
                debugPrint("CHHapticEngine reset")
                do {
                    try self?.hapticEngine?.start()
                    debugPrint("CHHapticEngine restarted after reset")
                } catch {
                    debugPrint("Failed to restart CHHapticEngine: \(error.localizedDescription)")
                }
            }
            
            hapticEngine?.stoppedHandler = { reason in
                debugPrint("CHHapticEngine stopped: \(reason.rawValue)")
            }
        } catch {
            debugPrint("Failed to create CHHapticEngine: \(error.localizedDescription)")
        }
    }
    
    func triggerHapticEngine() {
        debugPrint("Triggering CHHapticEngine haptic pattern")
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            debugPrint("Device does not support haptics")
            return
        }
        
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            
            debugPrint("Starting CHHapticEngine player")
            try player?.start(atTime: 0)
            debugPrint("CHHapticEngine haptic triggered successfully")
        } catch {
            debugPrint("Failed to trigger CHHapticEngine: \(error.localizedDescription)")
        }
    }
}

