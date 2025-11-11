import SwiftUI
import SPAvatarKit
import AVFoundation

struct CharacterDisplayPage: View {
    let characterName: String
    @ObservedObject var characterManager: SPCharacterManager
    let backgroundImage: UIImage?
    
    @State private var isConnected = false
    @State private var connectionState: SPAvatar.ConnectionState = .disconnected
    @State private var conversationState: SPAvatar.ConversationState = .idle
    @State private var playerState: SPAvatar.PlayerState = .idle
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var characterColor: Color {
        characterName == "A" ? .blue : .green
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Character display area
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height) - 20
                
                SPCharacterView(
                    characterManager: characterManager,
                    backgroundImage: backgroundImage,
                    isOpaque: true,
                    connectionStateDidUpdated: { state in
                        connectionState = state
                        isConnected = (state == .connected)
                    },
                    conversationStateDidUpdated: { state in
                        conversationState = state
                        print("Avatar \(characterName) - Conversation state: \(state)")
                    },
                    playerStateDidUpdated: { state in
                        playerState = state
                        print("Avatar \(characterName) - Player state: \(state)")
                    },
                    playerEncounteredError: { error in
                        errorMessage = "Player error: \(error)"
                        showError = true
                        print("Avatar \(characterName) - Player error: \(error)")
                    }
                )
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(characterColor, lineWidth: 2)
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .padding(10)
            
            // Control buttons
            VStack(spacing: 12) {
                // Connect/Disconnect button
                Button(action: {
                    toggleConnection()
                }) {
                    Text(isConnected ? "Disconnect" : "Connect")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isConnected ? Color.red : Color.green)
                        .cornerRadius(8)
                }
                
                // Audio buttons
                HStack(spacing: 12) {
                    Button(action: {
                        playAudio(fileName: "demo_pcm_audio1.pcm", end: false)
                    }) {
                        Text("  Send\nAudio 1")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                    .disabled(!isConnected)
                    
                    Button(action: {
                        playAudio(fileName: "demo_pcm_audio2.pcm", end: true)
                    }) {
                        Text("Send\nAudio 2 (End)")
                            .font(.system(size: 13, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                    .disabled(!isConnected)
                }
                
                // Interrupt button
                Button(action: {
                    characterManager.interrupt()
                }) {
                    Text("Interrupt")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .disabled(!isConnected)
            }
            .padding(16)
        }
        .navigationTitle("Avatar \(characterName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(characterColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
        .onDisappear {
            characterManager.close(shouldCleanup: true)
        }
    }
    
    private func toggleConnection() {
        if isConnected {
            characterManager.close(shouldCleanup: false)
        } else {
            characterManager.start()
        }
    }
    
    private func playAudio(fileName: String, end: Bool) {
        guard let audioPath = Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".pcm", with: ""), ofType: "pcm", inDirectory: "SPAvatarKitResources.bundle/audio") else {
            // Try without bundle path
            guard let audioPath = Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".pcm", with: ""), ofType: "pcm") else {
                errorMessage = "Audio file not found: \(fileName)"
                showError = true
                return
            }
            
            if let audioData = try? Data(contentsOf: URL(fileURLWithPath: audioPath)) {
                _ = characterManager.sendAudioData(audioData, end: end)
            } else {
                errorMessage = "Failed to load audio file"
                showError = true
            }
            return
        }
        
        do {
            let audioData = try Data(contentsOf: URL(fileURLWithPath: audioPath))
            _ = characterManager.sendAudioData(audioData, end: end)
        } catch {
            errorMessage = "Failed to play audio: \(error.localizedDescription)"
            showError = true
        }
    }
}

