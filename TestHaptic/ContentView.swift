//
//  ContentView.swift
//  TestHaptic
//
//  Created by Maksim Ponomarev on 11/5/25.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
	@StateObject private var cameraManager = CameraManager()
	@StateObject private var hapticManager = HapticManager()
	@StateObject private var videoRecordingManager = VideoRecordingManager()
	@State private var sensoryFeedbackTrigger = 0
	@State private var isHapticLogicUpdated = false
	
	var body: some View {
		ZStack {
			if cameraManager.isAuthorized {
				CameraPreviewView(session: cameraManager.session)
					.ignoresSafeArea()
					.onAppear {
						debugPrint("Camera preview appeared, starting session")
						cameraManager.startSession()
					}
					.onDisappear {
						debugPrint("Camera preview disappeared, stopping session")
						cameraManager.stopSession()
					}
				
				VStack {
					// Toggle at the top
					HStack {
						Button {
							setupAudioSession()
						} label: {
							Text("Setup Audio Session")
							
								.foregroundColor(.white)
								.padding(.horizontal, 24)
								.padding(.vertical, 14)
								.background(videoRecordingManager.isRecording ? Color.red : Color.red.opacity(0.8))
								.cornerRadius(12)
						}
						.padding()
						
						Spacer()
						Toggle("update haptic logic", isOn: $isHapticLogicUpdated)
							.onChange(of: isHapticLogicUpdated) { oldValue, newValue in
								debugPrint("Update haptic logic toggle changed: \(newValue)")
							}
							.padding()
							.background(Color.black.opacity(0.5))
							.cornerRadius(10)
							.padding(.top, 50)
							.padding(.trailing, 20)
					}
					
					Spacer()
					
					// Video Recording Button
					Button(action: {
						if videoRecordingManager.isRecording {
							debugPrint("Stop recording button tapped")
							videoRecordingManager.stopRecording()
						} else {
							debugPrint("Start recording button tapped")
							videoRecordingManager.startRecording()
						}
					}) {
						HStack {
							Image(systemName: videoRecordingManager.isRecording ? "stop.circle.fill" : "record.circle")
								.font(.system(size: 20))
							Text(videoRecordingManager.isRecording ? "Stop Recording" : "Start Recording")
								.font(.system(size: 16, weight: .bold))
						}
						.foregroundColor(.white)
						.padding(.horizontal, 24)
						.padding(.vertical, 14)
						.background(videoRecordingManager.isRecording ? Color.red : Color.red.opacity(0.8))
						.cornerRadius(12)
					}
					.padding(.bottom, 20)
					
					// Haptic Buttons
					HStack(spacing: 20) {
						// UIImpactFeedbackGenerator Button
						Button(action: {
							if isHapticLogicUpdated {
								try? AVAudioSession.sharedInstance().setActive(false)
							}
							debugPrint("UIImpactFeedbackGenerator button tapped")
							hapticManager.triggerImpactFeedback()
							
							if isHapticLogicUpdated {
								setupAudioSession()
							}
						}) {
							Text("UIImpactFeedbackGenerator")
								.font(.system(size: 14, weight: .semibold))
								.foregroundColor(.white)
								.padding(.horizontal, 16)
								.padding(.vertical, 12)
								.background(Color.blue)
								.cornerRadius(10)
						}
						
						// SensoryFeedback Button
						Button(action: {
							debugPrint("SensoryFeedback button tapped")
							sensoryFeedbackTrigger += 1
						}) {
							Text("SensoryFeedback")
								.font(.system(size: 14, weight: .semibold))
								.foregroundColor(.white)
								.padding(.horizontal, 16)
								.padding(.vertical, 12)
								.background(Color.green)
								.cornerRadius(10)
						}
						.sensoryFeedback(.impact(weight: .heavy), trigger: sensoryFeedbackTrigger)
						
						// CHHapticEngine Button
						Button(action: {
							debugPrint("CHHapticEngine button tapped")
							hapticManager.triggerHapticEngine()
						}) {
							Text("CHHapticEngine")
								.font(.system(size: 14, weight: .semibold))
								.foregroundColor(.white)
								.padding(.horizontal, 16)
								.padding(.vertical, 12)
								.background(Color.orange)
								.cornerRadius(10)
						}
					}
					.padding(.bottom, 50)
				}
				.onAppear {
					debugPrint("ContentView appeared, configuring camera with movie output")
					cameraManager.configure(with: videoRecordingManager.getMovieOutput())
				}
			} else {
				VStack(spacing: 20) {
					Image(systemName: "camera.fill")
						.font(.system(size: 60))
						.foregroundColor(.gray)
					
					Text("Camera Access Required")
						.font(.title2)
						.fontWeight(.semibold)
					
					Text("Please grant camera access in Settings")
						.font(.body)
						.foregroundColor(.secondary)
						.multilineTextAlignment(.center)
				}
				.padding()
			}
		}
		.task {
			//			setupAudioSession()
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
					//.mixWithOthers,
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
}

#Preview {
	ContentView()
}
