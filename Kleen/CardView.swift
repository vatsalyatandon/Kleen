import SwiftUI
import Photos
import UIKit

struct CardView: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil
    @State private var translation: CGSize = .zero
    
    var onRemove: (Bool) -> Void // true for keep (right), false for delete (left)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    ProgressView()
                }
                
                // Overlay for feedback
                if translation.width > 0 {
                    Text("KEEP")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 4)
                        )
                        .rotationEffect(.degrees(-15))
                        .opacity(Double(translation.width / 150))
                } else if translation.width < 0 {
                    Text("DELETE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 4)
                        )
                        .rotationEffect(.degrees(15))
                        .opacity(Double(-translation.width / 150))
                }
            }
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(Double(translation.width / 20)))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation
                    }
                    .onEnded { value in
                        if value.translation.width > 100 {
                            onRemove(true)
                        } else if value.translation.width < -100 {
                            onRemove(false)
                        } else {
                            withAnimation {
                                translation = .zero
                            }
                        }
                    }
            )
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 600, height: 800), contentMode: .aspectFill, options: options) { result, _ in
            self.image = result
        }
    }
}
