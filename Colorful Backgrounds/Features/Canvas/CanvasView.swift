//
//  CanvasView.swift
//  Colorful Backgrounds
//
//  Created by Adélaïde Sky on 01/07/2023.
//

import GIFImage
import SkyKit_Design
import SwiftUI

struct CanvasView: View {
    @ObservedObject var appSettings: AppSettings = .shared
    @ObservedObject var colors: SKColorMind = .shared

    var image: NSImage? = nil

    init() {}

    init(_ nsimage: NSImage) {
        self.image = nsimage
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                ZStack {
                    CanvasBackgroundView(colors: $colors.palette)
                    VStack {
                        Spacer()
                        if appSettings.titleText != "" {
                            VStack {
                                displayImage(geometry: geometry)
                                Spacer(minLength: .zero)
                                titleAndSubtitle()
                            }.padding()
                        } else {
                            displayImage(geometry: geometry)
                        }
                        Spacer()
                    }
                }
                .frame(width: min(CGFloat(appSettings.width), geometry.size.width),
                       height: min(CGFloat(appSettings.height), geometry.size.height))
                .cornerRadius(appSettings.roundedCorners ? 20 : 0)
                .clipped()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func displayImage(geometry: GeometryProxy) -> some View {
        Group {
            if image == nil {
                appSettings.gif
            } else {
                Image(nsImage: image!)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: min(CGFloat(Double(appSettings.width) * appSettings.gifSize), geometry.size.width),
               height: min(CGFloat(Double(appSettings.height) * appSettings.gifSize), geometry.size.height))
    }

    @ViewBuilder
    private func titleAndSubtitle() -> some View {
        Group {
            Text(appSettings.titleText)
                .font(.system(size: appSettings.subtitleText != "" ? max(Double(appSettings.height) / 5, Double(appSettings.height) / 5) : max(Double(appSettings.height) / 3, Double(appSettings.height) / 3)))
                .bold()
                .multilineTextAlignment(.center)
            if appSettings.subtitleText != "" {
                Text(appSettings.subtitleText)
                    .font(.system(size: 25))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
