import SwiftUI

struct FinishedView: View {
    var deletedCount: Int
    var errorMessage: String?
    var onCommit: () -> Void
    var onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                if let errorMessage = errorMessage {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("Oops!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                        .scaleEffect(1.2)
                        .padding()
                    
                    Text("All Done!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                if deletedCount > 0 {
                    Text("You marked \(deletedCount) photos for deletion.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: onCommit) {
                        Text("Delete \(deletedCount) Photos")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal, 40)
                } else {
                    Text("No photos were marked for deletion.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Button(action: onRestart) {
                    Text("Scan Again")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.top)
                
                Spacer()
            }
        }
    }
}
