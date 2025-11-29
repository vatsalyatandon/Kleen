import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Logo / Icon
                ZStack {
                    // Outer pulsing ring
                    Circle()
                        .stroke(
                            LinearGradient(gradient: Gradient(colors: [.blue, .purple, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 8
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotation))
                        .animation(Animation.linear(duration: 0.5).repeatForever(autoreverses: false), value: rotation)
                    
                    // Inner K Logoa
                    Text("K")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                        .animation(Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: scale)
                }
                
                Text("KLEEN")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .tracking(5) // Spacing
                    .opacity(0.8)
            }
        }
        .onAppear {
            rotation = 360
            scale = 1.2
        }
    }
}
