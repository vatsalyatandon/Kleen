import SwiftUI
import Photos

struct TrashView: View {
    let photosToDelete: [PHAsset]
    let onDismiss: () -> Void
    let onCommit: () -> Void
    let onRestore: (PHAsset) -> Void
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text("Trash")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                
                if photosToDelete.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        Text("No photos to delete")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    Text("Tap a photo to restore it")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(photosToDelete, id: \.localIdentifier) { asset in
                                TrashPhotoCell(asset: asset)
                                    .onTapGesture {
                                        withAnimation {
                                            onRestore(asset)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    
                    Button(action: onCommit) {
                        Text("Delete \(photosToDelete.count) Photos")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct TrashPhotoCell: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                ProgressView()
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options) { result, _ in
            self.image = result
        }
    }
}
