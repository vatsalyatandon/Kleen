//
//  OnboardingView.swift
//  Kleen
//
//  Created by Vatsalya Tandon on 29/11/25.
//


import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "arrow.left.and.right",
                        title: "Swipe to Clean",
                        description: "Swipe left to delete photos\nSwipe right to keep them"
                    ).tag(0)
                    
                    OnboardingPage(
                        icon: "trash",
                        title: "Batch Delete",
                        description: "Photos are queued for deletion\nDelete them all at once when ready"
                    ).tag(1)
                    
                    OnboardingPage(
                        icon: "sparkles",
                        title: "Keep It Clean",
                        description: "Quickly clean up your gallery\nand free up space"
                    ).tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 400)
                
                Button(action: {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        showOnboarding = false
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                if currentPage > 0 {
                    Button("Skip") {
                        showOnboarding = false
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
