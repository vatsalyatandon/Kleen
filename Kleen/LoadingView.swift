//
//  LoadingView.swift
//  Kleen
//
//  Created by Vatsalya Tandon on 29/11/25.
//


import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [.blue, .purple, .pink]), center: .center),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                
                Text("Loading Gallery...")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
