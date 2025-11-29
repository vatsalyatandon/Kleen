import SwiftUI

struct ContentView: View {
    @StateObject var photoManager = PhotoManager()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @State private var showTrashView = false
    @State private var showSplash = true // Start with splash screen
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if showSplash {
                LoadingView()
                    .transition(.opacity)
                    .zIndex(100)
                    .onAppear {
                        // Force splash for 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
            } else {
                mainContent
            }
        }
        .onChange(of: showOnboarding) { newValue in
            // When onboarding completes, request permission if needed
            if !newValue && !photoManager.permissionGranted {
                photoManager.requestPermission()
            }
        }
    }
    
    var mainContent: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if !photoManager.permissionGranted {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("Photo Access Required")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Kleen needs access to your photos to help you clean up your gallery.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        // Open Settings app
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }) {
                        Text("Open Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                }
            } else if photoManager.isLoading {
                LoadingView()
            } else if photoManager.photos.isEmpty && !photoManager.photosToDelete.isEmpty {
                // Finished state (Pending Deletion)
                FinishedView(
                    deletedCount: photoManager.photosToDelete.count,
                    errorMessage: photoManager.errorMessage,
                    onCommit: {
                        photoManager.commitDeletion()
                    },
                    onRestart: {
                        photoManager.fetchPhotos()
                    }
                )
                .transition(.opacity)
            } else if photoManager.photos.isEmpty && photoManager.photosToDelete.isEmpty {
                // Truly Empty (All Clean)
                VStack {
                    Image(systemName: "sparkles")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.yellow)
                        .padding()
                    Text("Gallery Clean!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Button("Scan Again") {
                        photoManager.fetchPhotos()
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
            } else {
                // Feed state
                ZStack {
                    VStack {
                        // Top Bar
                        HStack(alignment: .center) {
                            // Left: Kleen Title
                            Text("Kleen")
                                .font(.system(size: 34, weight: .bold, design: .default)) // Cleaner, standard font
                                .foregroundColor(.white)
                                .tracking(0.5)
                            
                            Spacer()
                            
                            // Right: Actions
                            HStack(spacing: 16) {
                                // Manage Photos Button (if limited)
                                if photoManager.isLimited {
                                    Button(action: {
                                        photoManager.presentLimitedLibraryPicker()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // Trash Button
                                HStack(spacing: 6) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("\(photoManager.photosToDelete.count)")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(photoManager.photosToDelete.count > 0 ? Color.red : Color.gray.opacity(0.5))
                                )
                                .onTapGesture {
                                    withAnimation {
                                        showTrashView = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .zIndex(10) // Ensure HStack is above cards
                        
                        ZStack {
                            // Show max 2 cards for stability and cleaner look
                            let topPhotos = Array(photoManager.photos.prefix(2))
                            
                            // We reverse so the first item (top card) is rendered LAST (on top of ZStack)
                            ForEach(Array(topPhotos.enumerated()).reversed(), id: \.element.localIdentifier) { index, asset in
                                CardView(asset: asset) { kept in
                                    if !kept {
                                        photoManager.deletePhoto(asset: asset)
                                    } else {
                                        if let index = photoManager.photos.firstIndex(of: asset) {
                                            photoManager.photos.remove(at: index)
                                        }
                                        // Mark as kept
                                        photoManager.keepPhoto(asset: asset)
                                    }
                                    
                                    // Load more photos if running low
                                    if photoManager.photos.count < 5 {
                                        photoManager.loadMorePhotos()
                                    }
                                }
                                // Stack Effect Logic
                                .zIndex(Double(topPhotos.count - index)) // Ensure correct layering
                                .scaleEffect(index == 0 ? 1.0 : 0.96) // Subtle scale for back card
                                .offset(y: index == 0 ? 0 : 0) // No vertical offset, just hide behind
                                .opacity(1.0) // Always visible (static back card)
                                .padding()
                                .transition(.identity) // No transition for the stack itself
                                .allowsHitTesting(index == 0) // Only top card is interactive
                            }
                        }
                        .animation(.spring(), value: photoManager.photos)
                        
                        Spacer()
                        
                        // Progress Bar at bottom
                        if photoManager.totalCount > 0 {
                            ProgressBar(
                                totalCount: photoManager.totalCount,
                                reviewedCount: photoManager.reviewedCount
                            )
                            .transition(.move(edge: .bottom))
                        }
                    }
                    
                    // Trash view overlay
                    if showTrashView {
                        TrashView(
                            photosToDelete: photoManager.photosToDelete,
                            onDismiss: {
                                withAnimation {
                                    showTrashView = false
                                }
                            },
                            onCommit: {
                                photoManager.commitDeletion()
                                withAnimation {
                                    showTrashView = false
                                }
                            },
                            onRestore: { asset in
                                photoManager.restorePhoto(asset: asset)
                            }
                        )
                        .zIndex(1)
                        .transition(.move(edge: .trailing))
                    }
                }
                .animation(.easeInOut, value: showTrashView)
            }
        }
    }
}
