import SwiftUI

struct ProgressBar: View {
    let totalCount: Int
    let reviewedCount: Int
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(reviewedCount) / Double(totalCount)
    }
    
    var remainingCount: Int {
        max(0, totalCount - reviewedCount)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Stats Row
            HStack {
                Text("\(reviewedCount) reviewed")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(remainingCount) remaining")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    // Progress Fill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
            
            // Percentage
            Text("\(Int(progress * 100))% complete")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.5))
    }
}
