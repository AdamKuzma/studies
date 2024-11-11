//
//  3D Carousel.swift
//  Studies
//
//  Created by Adam Kuzma on 11/10/24.
//

import SwiftUI

struct TransitionCardA: Identifiable {
    let id = UUID()
    let color: Color
    let title: String
}

struct TransitionCardAView: View {
    let card: TransitionCardA
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(card.color)
            .overlay(
                Text(card.title)
                    .font(.title)
                    .foregroundColor(.white)
            )
            .frame(width: 200, height: 200)
            .shadow(radius: 5)
    }
}

struct TransitionDemoAView: View {
    let cards = [
        TransitionCardA(color: .gray, title: "Card 1"),
        TransitionCardA(color: .gray, title: "Card 2"),
        TransitionCardA(color: .gray, title: "Card 3"),
        TransitionCardA(color: .gray, title: "Card 4"),
        TransitionCardA(color: .gray, title: "Card 5")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(cards) { card in
                    TransitionCardAView(card: card)
                        .scrollTransition { content, phase in
                            content
                                
                                // Scale Effects
                                .scaleEffect(phase == .identity ? 1.0 : 0.8)  // Overall scale
                                .scaleEffect(x: phase == .identity ? 1.0 : 0.7)  // X-axis only
                                .scaleEffect(y: phase == .identity ? 1.0 : 0.7)  // Y-axis only
                            
                                // Rotation Effects
                                .rotationEffect(.degrees(phase == .identity ? 0 : 0))
                                .rotation3DEffect(
                                    .degrees(phase == .identity ? 0 : 20),
                                    axis: (x: 0, y: 1, z: 0)  // 3D rotation around X axis
                                )
                            
                                // Position Effects
                                .offset(x: phase == .identity ? 0 : 0)  // Horizontal offset
                                .offset(y: phase == .identity ? 0 : 50)  // Vertical offset
                            
                                // Transparency
                                .opacity(phase == .identity ? 1.0 : 0.5)
                                
                                // Color Effects
                                .saturation(phase == .identity ? 1.0 : 0.5)
                                .brightness(phase == .identity ? 0 : -0.2)
                                .contrast(phase == .identity ? 1.0 : 0.8)
                                
                                // Blur Effect
                                .blur(radius: phase == .identity ? 0 : 5)
                            
                            
                        }
                        .visualEffect { content, geometry in
                            content
                                // Try different parallax strengths
                                .offset(x: geometry.frame(in: .scrollView).minX / 5)
                            
                                // Try different blur amounts
                                .blur(radius: abs(geometry.frame(in: .scrollView).minX / 200))
                        }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 90) // Left edge spacing
        }
        .scrollTargetBehavior(.viewAligned)
    }
}

#Preview {
    TransitionDemoAView()
}
