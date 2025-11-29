import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Darker background for better contrast
            Color(red: 0.05, green: 0.05, blue: 0.05).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // Logo / Icon
                ZStack {
                    // Outer pulsing ring - much larger and brighter
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple, .pink, .blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 12
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(rotation))
                        .animation(Animation.linear(duration: 0.8).repeatForever(autoreverses: false), value: rotation)
                    
                    // Inner K Logo - much larger and brighter
                    Text("K")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                        .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: scale)
                        .shadow(color: .blue, radius: 20)
                }
                
                // Brand name - larger and brighter
                VStack(spacing: 10) {
                    Text("KLEEN")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(8)
                        .shadow(color: .white.opacity(0.3), radius: 10)
                    
                    Text("Loading your photos...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            rotation = 360
            scale = 1.15
        }
    }
}
