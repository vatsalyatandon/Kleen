import SwiftUI
import Photos
import UIKit

struct CardView: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil
    @State private var translation: CGSize = .zero
    @State private var showDetails = false
    
    var onRemove: (Bool) -> Void // true for keep (right), false for delete (left)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main Image
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    ZStack {
                        Color(UIColor.systemGray6)
                        ProgressView()
                    }
                }
                
                // Gradient Overlay for Text Readability
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Metadata (Date & Size)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(asset.creationDate?.formatted(date: .long, time: .omitted) ?? "Unknown Date")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("\(asset.pixelWidth) x \(asset.pixelHeight)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    
                    // Info Icon
                    Button(action: {
                        showDetails = true
                    }) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                            .shadow(radius: 2)
                    }
                }
                .padding()
                .padding(.bottom, 20)
                
                // Stamps (KEEP / DELETE)
                VStack {
                    HStack {
                        if translation.width > 0 {
                            Text("KEEP")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 4)
                                )
                                .rotationEffect(.degrees(-15))
                                .opacity(Double(translation.width / 100))
                                .padding(.top, 40)
                                .padding(.leading, 40)
                            Spacer()
                        } else if translation.width < 0 {
                            Spacer()
                            Text("DELETE")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.red)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red, lineWidth: 4)
                                )
                                .rotationEffect(.degrees(15))
                                .opacity(Double(-translation.width / 100))
                                .padding(.top, 40)
                                .padding(.trailing, 40)
                        }
                    }
                    Spacer()
                }
            }
            .background(Color.black)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .offset(x: translation.width, y: translation.height)
            .rotationEffect(.degrees(Double(translation.width / 20)))
            .scaleEffect(translation.width != 0 ? 1.05 : 1.0) // Subtle pop on drag
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
                            withAnimation(.spring()) {
                                translation = .zero
                            }
                        }
                    }
            )
            .sheet(isPresented: $showDetails) {
                PhotoDetailView(asset: asset)
            }
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
        options.resizeMode = .exact
        
        // Request a slightly larger image for better quality on Retina displays
        let targetSize = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
        
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { result, _ in
            withAnimation {
                self.image = result
            }
        }
    }
}
