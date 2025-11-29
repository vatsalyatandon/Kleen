import SwiftUI

struct ContentView: View {
    @StateObject var photoManager = PhotoManager()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @State private var showTrashView = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if showOnboarding {
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
                VStack {
                    Text("Permission Required")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    Button("Grant Access") {
                        photoManager.requestPermission()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
                        HStack {
                            if photoManager.isLimited {
                                Button(action: {
                                    photoManager.presentLimitedLibraryPicker()
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                }
                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("\(photoManager.photosToDelete.count)")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(photoManager.photosToDelete.count > 0 ? Color.red : Color.gray)
                            .cornerRadius(20)
                            .onTapGesture {
                                withAnimation {
                                    showTrashView = true
                                }
                            }
                            .padding()
                        }
                        .zIndex(10) // Ensure HStack is above cards
                        
                        ZStack {
                            ForEach(Array(photoManager.photos.prefix(3).reversed()), id: \.localIdentifier) { asset in
                                CardView(asset: asset) { kept in
                                    if !kept {
                                        photoManager.deletePhoto(asset: asset)
                                    } else {
                                        if let index = photoManager.photos.firstIndex(of: asset) {
                                            photoManager.photos.remove(at: index)
                                        }
                                    }
                                }
                                .padding()
                                .transition(.scale)
                            }
                        }
                        .animation(.spring(), value: photoManager.photos)
                        
                        Spacer()
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
