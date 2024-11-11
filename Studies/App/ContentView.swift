//
//  ContentView.swift
//  Studies
//
//  Created by Adam Kuzma on 11/6/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Divider()
                ProjectRow(number: "01", title: "Basic Carousel", destination: AnyView(BasicCarouselPreview()))
                Divider()
                ProjectRow(number: "02", title: "Advanced Carousel", destination: AnyView(BasicCarouselPreview()))
                Divider()
                ProjectRow(number: "03", title: "UIKit Carousel", destination: AnyView(BasicCarouselPreview()))
                Divider()
            }
            .navigationTitle("All Projects")
            .padding(.top, 20)
        }
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
