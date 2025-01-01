//
//  ParticleAnimation.swift
//  Studies
//
//  Created by Adam Kuzma on 1/1/25.
//

import SwiftUI
import UIKit

struct ParticleTextAnimation: View {
    
    let text: String
    let particleCount = 1000
        
    @State private var particles: [Particle] = []
    @State private var dragPosition: CGPoint?
    @State private var dragVelocity: CGSize?
    @State private var size: CGSize = .zero
    
    
    let timer = Timer.publish(every: 1/120, on: .main, in: .common).autoconnect()
        
    var body: some View {
        
        Canvas { context, size in
            context.blendMode = .normal
            
            for particle in particles {
                let path = Path(ellipseIn: CGRect(
                    x: particle.x,
                    y: particle.y,
                    width: particle.size,
                    height: particle.size
                ))
                context.fill(path, with: .color(.primary.opacity(0.7)))
            }
        }
        
        .onReceive(timer){ _ in
            updateParticles()
        }
        .onChange(of:text){
            createParticles()
        }
        .onAppear {
            createParticles()
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    dragPosition = value.location
                    dragVelocity = value.velocity
                    triggerHapticFeedback()
                }
            
                .onEnded { value in
                    dragPosition = nil
                    dragVelocity = nil
                    updateParticles()
                }
            
        )
        
        .background(.background)
        .overlay(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        size = geometry.size
                        createParticles()
                    }
            }
        )
    }
    
    
    
    private func createParticles() {
        let renderer = ImageRenderer(content: Text(text)
            .font(.system(size: 240, design: .rounded))
            .bold())
        
        renderer.scale = 1.0
        
        guard let image = renderer.uiImage else { return }
        guard let cgImage = image.cgImage else { return }
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        guard let pixelData = cgImage.dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else { return }
        
        let offsetX = (size.width - CGFloat(width)) / 2
        let offsetY = (size.height - CGFloat(height)) / 2
        
        particles = (0..<particleCount).map { _ in
            var x, y: Int
            var isEdge = false
            
            // Keep trying positions until we find one on the text
            repeat {
                x = Int.random(in: 0..<width)
                y = Int.random(in: 0..<height)
                
                // Check if current position is part of the text
                let currentPixel = data[((width * y) + x) * 4 + 3] >= 128
                
                if currentPixel {
                    // Check surrounding pixels to determine if we're near an edge
                    let checkRadius = 2
                    var surroundingPixels = 0
                    var totalChecked = 0
                    
                    for offsetY in -checkRadius...checkRadius {
                        for offsetX in -checkRadius...checkRadius {
                            let checkX = x + offsetX
                            let checkY = y + offsetY
                            
                            // Skip if outside image bounds
                            if checkX < 0 || checkX >= width || checkY < 0 || checkY >= height {
                                continue
                            }
                            
                            if data[((width * checkY) + checkX) * 4 + 3] >= 128 {
                                surroundingPixels += 1
                            }
                            totalChecked += 1
                        }
                    }
                    
                    // If less than 80% of surrounding pixels are part of the text,
                    // consider this an edge
                    isEdge = Double(surroundingPixels) / Double(totalChecked) < 0.8
                }
                
            } while data[((width * y) + x) * 4 + 3] < 128
            
            // Determine particle size based on edge status
            let particleSize = isEdge ? Double.random(in: 2.5...3.5) : 2.0
            
            return Particle(
                x: Double.random(in: -size.width...size.width*2),
                y: Double.random(in: 0...size.height * 2),
                baseX: Double(x) + offsetX,
                baseY: Double(y) + offsetY,
                density: Double.random(in: 5...20),
                size: particleSize
            )
        }
    }
    
    
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].update(dragPosition: dragPosition, dragVelocity: dragVelocity)
        }
    }
}



func triggerHapticFeedback() {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
}
