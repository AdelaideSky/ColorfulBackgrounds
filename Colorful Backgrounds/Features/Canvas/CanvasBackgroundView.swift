//
//  CanvasBackgroundView.swift
//  Colorful Backgrounds
//
//  Created by Adélaïde Sky on 01/07/2023.
//

import SwiftUI
import SkyKit_Design

struct CanvasBackgroundView: View {
    @ObservedObject var appSettings = AppSettings.shared
    @Binding var colors: [Color]
    
    var body: some View {
        VStack {
            if colors.count > 4 {
                ZStack {
                    AngularGradient(colors: colors, center: .center)
                        .saturation(2)
                        .scaleEffect(1.5)
                        .blur(radius: 100)
                    if let nsImage = appSettings.noiseTexture {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFill()
                            .opacity(appSettings.noiseAmount)
                    }
                    
                }
            }
        }
    }
}

