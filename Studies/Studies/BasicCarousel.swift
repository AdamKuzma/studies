//
//  Carousel.swift
//  Studies
//
//  Created by Adam Kuzma on 11/6/24.
//

import SwiftUI

struct CardCarousel<Content: View>: View {
    let items: [Content]
    
    // Customizable properties
    private let maxCardWidth: CGFloat = 280
    private let cardHeight: CGFloat = 250
    private let spacing: CGFloat = 16
    
    private let minScale: CGFloat = 0.8
    private let minOpacity: CGFloat = 0.5
    
    init(_ items: [Content]) {
        self.items = items
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                ForEach(0..<items.count, id: \.self) { index in
                    GeometryReader { geometry in
                        items[index]
                            .frame(width: maxCardWidth, height: cardHeight)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .scaleEffect(scale(for: geometry))
                            .opacity(opacity(for: geometry))
                            .animation(.easeOut(duration: 0.2), value: geometry.frame(in: .global).minX)
                    }
                    .frame(width: maxCardWidth)
                }
            }
            .scrollTargetLayout()
            .frame(height: cardHeight)
            .padding(.horizontal, UIScreen.main.bounds.width / 2 - maxCardWidth / 2)
        }
        .scrollTargetBehavior(.viewAligned)
    }
    
    private func scale(for geometry: GeometryProxy) -> CGFloat {
        let screenCenter = UIScreen.main.bounds.width / 2
        let offset = geometry.frame(in: .global).minX
        let cardCenter = offset + maxCardWidth / 2
        let distanceFromCenter = abs(cardCenter - screenCenter)
        
        let maxScale: CGFloat = 1.0
        let maxDistance = maxCardWidth
        
        if distanceFromCenter > maxDistance {
            return minScale
        } else {
            return maxScale - (distanceFromCenter / maxDistance) * (maxScale - minScale)
        }
    }
    
    private func opacity(for geometry: GeometryProxy) -> CGFloat {
        let screenCenter = UIScreen.main.bounds.width / 2
        let offset = geometry.frame(in: .global).minX
        let cardCenter = offset + maxCardWidth / 2
        let distanceFromCenter = abs(cardCenter - screenCenter)
        
        let maxOpacity: CGFloat = 1.0
        let maxDistance = maxCardWidth
        
        if distanceFromCenter > maxDistance {
            return minOpacity
        } else {
            return maxOpacity - (distanceFromCenter / maxDistance) * (maxOpacity - minOpacity)
        }
    }
}

struct CardView: View {
    let title: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
    }
}

// Preview View
struct BasicCarouselPreview: View {
    var body: some View {
        CardCarousel([
            CardView(title: "Card 1", color: .gray),
            CardView(title: "Card 2", color: .gray),
            CardView(title: "Card 3", color: .gray),
            CardView(title: "Card 4", color: .gray)
        ])
    }
}

#Preview {
    BasicCarouselPreview()
}
