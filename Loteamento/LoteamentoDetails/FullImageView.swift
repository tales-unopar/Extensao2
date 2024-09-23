//
//  FullImageView.swift
//  Loteamento
//
//  Created by Tales on 23/09/24.
//

import SwiftUI

struct FullImageView: View {
    let image: UIImage
    
    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
