//
//  Goat Carousel.swift
//  Studies
//
//  Created by Adam Kuzma on 11/10/24.
//

import SwiftUI

struct GoatCarousel: View {
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(0..<10) { index in
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .frame(width: 300, height: 500)
                            .scrollTransition(.interactive.animation(.smooth).threshold(.visible(3))) { view, phase in
                                view
                                    .rotation3DEffect(.degrees(-12), axis: (x: 0, y: 1, z: 0), perspective: 0.8)
                                    .scaleEffect(scale(phase:phase), anchor: .leading)
                            }
                            .zIndex(-Double(index))
                    }
                }
            }
            .scrollClipDisabled()
        }
    }
    
    
    func scale(phase: ScrollTransitionPhase) -> CGFloat {
        switch phase {
        case .topLeading:
            1.1
        case .identity:
            1
        case .bottomTrailing:
            0.6
        }
    }
}

#Preview {
    GoatCarousel()
}

