//
//  LogoView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct LogoView: View {
    var size: CGFloat = 100
    var showText: Bool = true
    
    var body: some View {
        VStack(spacing: 12) {
            // Logo Icon - Using SF Symbols to represent the educational icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Educational icon representation
                VStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.3))
                        .foregroundColor(.white)
                    
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: size * 0.25))
                        .foregroundColor(.white)
                        .offset(x: size * 0.15, y: -size * 0.1)
                    
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: size * 0.2))
                        .foregroundColor(.white)
                        .offset(x: size * 0.2, y: -size * 0.15)
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

