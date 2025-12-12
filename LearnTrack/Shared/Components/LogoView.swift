
import SwiftUI

struct LogoView: View {
    var size: CGFloat = 100
    var showText: Bool = true
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .frame(width: size, height: size)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .offset(x: -size * 0.2, y: size * 0.05)
                
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.1)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .frame(width: size * 0.55, height: size * 0.45)
                        .offset(x: size * 0.15, y: -size * 0.1)
                    
                    Path { path in
                        let tailSize = size * 0.12
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: tailSize * 0.8, y: tailSize * 0.6))
                        path.addLine(to: CGPoint(x: tailSize * 0.3, y: tailSize))
                        path.closeSubpath()
                    }
                    .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .offset(x: -size * 0.1, y: -size * 0.15)
                    
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: size * 0.28))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        .offset(x: size * 0.2, y: -size * 0.1)
                }
            }
            
            if showText {
                VStack(spacing: 4) {
                    Text("LearnTrack")
                        .font(.system(size: size * 0.3, weight: .bold))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Gestion de formations")
                        .font(.system(size: size * 0.15))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LogoView(size: 120)
        LogoView(size: 80, showText: false)
    }
    .padding()
}

