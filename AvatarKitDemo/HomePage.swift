import SwiftUI
import SPAvatarKit

struct HomePage: View {
    @State private var isLoading = false
    @State private var loadingCharacterName = ""
    @State private var characterManager: SPCharacterManager?
    @State private var backgroundImage: UIImage?
    @State private var loadProgress: Float = 0.0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToDisplay = false
    
    private let characterId = "e41f7ee0-3807-4956-b169-1becf8497ebc"
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Avatar A Button
                    Button(action: {
                        loadAndNavigate(characterName: "A")
                    }) {
                        Text("Load Avatar A")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    
                    // Avatar B Button
                    Button(action: {
                        loadAndNavigate(characterName: "B")
                    }) {
                        Text("Load Avatar B")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    
                    Spacer()
                }
                .padding(32)
                
                // Loading overlay
                if isLoading {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Loading Avatar \(loadingCharacterName)...")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        if loadProgress > 0 {
                            Text("\(Int(loadProgress * 100))%")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .navigationTitle("Avatar Demo")
            .navigationDestination(isPresented: $navigateToDisplay) {
                if let manager = characterManager {
                    CharacterDisplayPage(
                        characterName: loadingCharacterName,
                        characterManager: manager,
                        backgroundImage: backgroundImage
                    )
                }
            }
            .alert("Loading Failed", isPresented: $showError) {
                Button("OK", role: .cancel) {
                    errorMessage = ""
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadAndNavigate(characterName: String) {
        isLoading = true
        loadingCharacterName = characterName
        loadProgress = 0.0
        
        Task {
            do {
                // Load background image
                if let imagePath = Bundle.main.path(forResource: "background", ofType: "jpeg", inDirectory: "SPAvatarKitResources.bundle/image") {
                    backgroundImage = UIImage(contentsOfFile: imagePath)
                }
                
                // Load character
                let character = await SPCharacterLoader.shared.loadCharacter(characterId) { state in
                    Task { @MainActor in
                        handleLoadState(state)
                    }
                }
                
                guard let character = character else {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Failed to load character"
                        showError = true
                    }
                    return
                }
                
                // Create character manager
                await MainActor.run {
                    characterManager = SPCharacterManager(character: character)
                    isLoading = false
                    navigateToDisplay = true
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Error: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    @MainActor
    private func handleLoadState(_ state: SPCharacterLoader.LoadState) {
        switch state {
        case .preparing:
            loadProgress = 0.0
            
        case .downloading(let progress):
            loadProgress = progress.progress
            
        case .completed:
            loadProgress = 1.0
            
        case .failed(let error):
            isLoading = false
            errorMessage = error.reason
            showError = true
            
        case .info(let message):
            print("Load info: \(message)")
        }
    }
}

#Preview {
    HomePage()
}

