import SwiftUI

struct TransitionCard: Identifiable {
    let id = UUID()
    let material: Material
    let title: String
}

struct TransitionCardView: View {
    let card: TransitionCard
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(card.material)
            .overlay(
                Text(card.title)
                    .font(.title)
                    .foregroundColor(.white)
            )
            .frame(width: 200, height: 200)
            .shadow(radius: 5)
    }
}

struct TransitionDemoView: View {
    let cards = [
        TransitionCard(material: .ultraThinMaterial, title: "Card 1"),
        TransitionCard(material: .ultraThinMaterial, title: "Card 2"),
        TransitionCard(material: .ultraThinMaterial, title: "Card 3"),
        TransitionCard(material: .ultraThinMaterial, title: "Card 4"),
        TransitionCard(material: .ultraThinMaterial, title: "Card 5")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(cards) { card in
                    TransitionCardView(card: card)
                        .scrollTransition { content, phase in
                            content
                                // Try different scale values
                                .scaleEffect(phase == .identity ? 1.0 : 0.8)
                            
                                // Try different rotation values
                                .rotationEffect(.degrees(phase == .identity ? 0 : -10))
                            
                                // Try different opacity values
                                .opacity(phase == .identity ? 1.0 : 0.5)
                            
                                // Try different offset values
                                .offset(y: phase == .identity ? 0 : 100)
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
        .frame(height: 600) // Height of the container
    }
}

#Preview {
    TransitionDemoView()
}
