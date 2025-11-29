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
                    Text("No photos to clean!")
                        .font(.title)
                        .foregroundColor(.gray)
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
                Text("Please grant photo library access in Settings.")
                    .padding()
            }
        }
    }
}
