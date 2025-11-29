import SwiftUI

struct LoadingView: View {
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Kleen")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .tracking(2)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.0)) {
                            opacity = 1.0
                        }
                    }
                
                // Optional: Subtle loading indicator if needed, but for splash it's cleaner without
            }
        }
    }
}
