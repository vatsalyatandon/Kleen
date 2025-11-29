import SwiftUI

struct ContentView: View {
    @StateObject var photoManager = PhotoManager()
    
    var body: some View {
        VStack {
            Text("Gallery Cleaner")
                .font(.headline)
                .padding()
            
            if photoManager.permissionGranted {
                if photoManager.photos.isEmpty {
                    VStack {
                        Text("No photos found.")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("Check if your simulator/device has photos.")
                            .font(.caption)
                    }
                } else {
                    ZStack {
                        ForEach(Array(photoManager.photos.prefix(3).reversed()), id: \.localIdentifier) { asset in
                            CardView(asset: asset) { kept in
                                if !kept {
                                    photoManager.deletePhoto(asset: asset)
                                } else {
                                    // Just remove from the list to show next
                                    if let index = photoManager.photos.firstIndex(of: asset) {
                                        photoManager.photos.remove(at: index)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            } else {
                VStack {
                    Text("Permission not granted.")
                        .padding()
                    Button("Request Permission") {
                        photoManager.requestPermission()
                    }
                }
            }
        }
        .onAppear {
            print("ContentView appeared")
        }
    }
}
