//
//  Advanced Carousel.swift
//  Studies
//
//  Created by Adam Kuzma on 11/6/24.
//

import SwiftUI

struct AdvCardCarousel<Content: View>: View {
    let items: [Content]
    
    // Customizable properties
    private let maxCardWidth: CGFloat = 250
    private let cardHeight: CGFloat = 350
    private let spacing: CGFloat = -180
    private let minScale: CGFloat = 0.8
    private let maxScale: CGFloat = 1.2  // Maximum scale for left side cards
    
    // Separate rotation values for left and right
    private let leftRotation: Double = 20
    private let rightRotation: Double = 20
    
    // Separate vertical offset values for left and right
    private let leftVerticalOffset: CGFloat = 20
    private let rightVerticalOffset: CGFloat = 20
    
    // Center card position offset
    private let centerOffset: CGPoint = CGPoint(x: 0, y: 0)
    
    
    init(_ items: [Content]) {
        self.items = items
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(Array(items.indices), id: \.self) { index in
                    GeometryReader { geometry in
                        items[index]
                            .scaleEffect(scale(for: geometry))
                            .rotationEffect(.degrees(180))
                            .rotation3DEffect(
                                .degrees(rotation(for: geometry)),
                                axis: (x: 0, y: 0, z: 1)
                            )
                            .offset(y: verticalOffset(for: geometry))
                            .offset(x: xOffset(for: geometry), y: yOffset(for: geometry))
                            .animation(.easeOut(duration: 0.2), value: geometry.frame(in: .global).minX)
                    }
                    .frame(width: maxCardWidth)
                }
            }
            .frame(height: cardHeight)
            .padding(.vertical, (cardHeight * maxScale - cardHeight) / 2 + abs(min(leftVerticalOffset, rightVerticalOffset)))  // Add extra padding for vertical offset
            .padding(.horizontal, UIScreen.main.bounds.width / 2 - maxCardWidth / 2)
            .rotationEffect(.degrees(180))
        }
        .frame(height: cardHeight * maxScale + abs(min(leftVerticalOffset, rightVerticalOffset)) * 2)  // Account for vertical offset
    }
    
    private func xOffset(for geometry: GeometryProxy) -> CGFloat {
        let screenCenter = UIScreen.main.bounds.width / 2
        let offset = geometry.frame(in: .global).minX
        let cardCenter = offset + maxCardWidth / 2
        let distanceFromCenter = cardCenter - screenCenter
        
        // Gradually blend the center offset as cards move away from center
        let centerBlend = 1 - min(abs(distanceFromCenter) / maxCardWidth, 1)
        return centerOffset.x * centerBlend
    }
    
    private func yOffset(for geometry: GeometryProxy) -> CGFloat {
        let screenCenter = UIScreen.main.bounds.width / 2
        let offset = geometry.frame(in: .global).minX
        let cardCenter = offset + maxCardWidth / 2
        let distanceFromCenter = cardCenter - screenCenter
        let percentageFromCenter = distanceFromCenter / maxCardWidth
        
        // Calculate vertical offset based on side position
        let sideOffset = cardCenter < screenCenter ?
            (percentageFromCenter * leftVerticalOffset) :
            (percentageFromCenter * rightVerticalOffset)
        
        // Blend with center offset
        let centerBlend = 1 - min(abs(distanceFromCenter) / maxCardWidth, 1)
        return sideOffset + (centerOffset.y * centerBlend)
    }
    
    
    private func verticalOffset(for geometry: GeometryProxy) -> CGFloat {
        let screenCenter = UIScreen.main.bounds.width / 2
        let offset = geometry.frame(in: .global).minX
        let cardCenter = offset + maxCardWidth / 2
        let distanceFromCenter = cardCenter - screenCenter
        let percentageFromCenter = distanceFromCenter / maxCardWidth
        
        if cardCenter < screenCenter {  // Left side
            return percentageFromCenter * leftVerticalOffset
        } else {  // Right side
            return percentageFromCenter * rightVerticalOffset
        }
    }
    
    private func rotation(for geometry: GeometryProxy) -> Double {
        let screenCenter = UIScreen.main.bounds.width / 2
        let offset = geometry.frame(in: .global).minX
        let cardCenter = offset + maxCardWidth / 2
        let distanceFromCenter = cardCenter - screenCenter
        let percentageFromCenter = distanceFromCenter / maxCardWidth
        
        if cardCenter < screenCenter {  // Left side
            return percentageFromCenter * leftRotation
        } else {  // Right side
            return percentageFromCenter * rightRotation
        }
    }
    
    private func scale(for geometry: GeometryProxy) -> CGFloat {
        let screenCenter = UIScreen.main.bounds.width / 2
        let offset = geometry.frame(in: .global).minX
        let cardCenter = offset + maxCardWidth / 2
        let distanceFromCenter = abs(cardCenter - screenCenter)
        let maxDistance = maxCardWidth
        
        if cardCenter < screenCenter {  // Left side
            if distanceFromCenter > maxDistance {
                return maxScale
            } else {
                return 1.0 + (distanceFromCenter / maxDistance) * (maxScale - 1.0)
            }
        } else {  // Right side
            if distanceFromCenter > maxDistance {
                return minScale
            } else {
                return 1.0 - (distanceFromCenter / maxDistance) * (1.0 - minScale)
            }
        }
    }
}

struct AdvCardView: View {
    let title: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(.ultraThinMaterial)
            
            VStack {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .frame(width: 250, height: 350)
        .cornerRadius(5)
        .shadow(radius: 5)
    }
}

struct AdvCarouselPreview: View {
    var body: some View {
        AdvCardCarousel([
            AdvCardView(title: "Card 1"),
            AdvCardView(title: "Card 2"),
            AdvCardView(title: "Card 3"),
            AdvCardView(title: "Card 4"),
            AdvCardView(title: "Card 5"),
            AdvCardView(title: "Card 2"),
            AdvCardView(title: "Card 3"),
            AdvCardView(title: "Card 4"),
            AdvCardView(title: "Card 5")
        ])
    }
}

#Preview {
    AdvCarouselPreview()
}
