//
//  CardView.swift
//  Loteamento
//
//  Created by Tales on 23/09/24.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
            )
    }
}
