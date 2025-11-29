import SwiftUI

struct ContentView: View {
    @StateObject var photoManager = PhotoManager()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Dark mode background
            
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
                        
                        Button(action: {
                            // Undo or show list? For now just a placeholder or count
                            print("Trash count: \(photoManager.photosToDelete.count)")
                        }) {
                            Text("Trash: \(photoManager.photosToDelete.count)")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    
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
            }
        }
    }
}
