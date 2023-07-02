//
//  CanvasView.swift
//  Colorful Backgrounds
//
//  Created by Adélaïde Sky on 01/07/2023.
//

import SwiftUI
import SkyKit_Design
import GIFImage

struct CanvasView: View {
    @ObservedObject var appSettings: AppSettings = .shared
    @ObservedObject var colors: SKColorMind = .shared
    
    var image: NSImage? = nil
    
    
    init() {}
    
    init(_ nsimage: NSImage) {
        image = nsimage
    }

    var body: some View {
        VStack {
            ZStack {
                CanvasBackgroundView(colors: $colors.palette)
                VStack {
                    Spacer()
                    if appSettings.titleText != "" {
                        VStack {
                            if appSettings.gif != nil {
                                Group {
                                    if image == nil {
                                        appSettings.gif
                                    } else {
                                        Image(nsImage: image!)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }.frame(width: CGFloat(Double(appSettings.width)*appSettings.gifSize), height: CGFloat(Double(appSettings.height)*appSettings.gifSize))
                            }
                            Spacer(minLength: .zero)
                            Group {
                                Text(appSettings.titleText)
                                    .font(.system(size: appSettings.subtitleText != "" ? max(Double(appSettings.height)/5, Double(appSettings.height)/5) : max(Double(appSettings.height)/3, Double(appSettings.height)/3)))
                                    .bold()
                                    .multilineTextAlignment(.center)
                                if appSettings.subtitleText != "" {
                                    Text(appSettings.subtitleText)
                                        .font(.system(size: 25))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            Spacer(minLength: .zero)
                        }.padding()
                    } else {
                        Group {
                            if image == nil {
                                appSettings.gif
                            } else {
                                Image(nsImage: image!)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }.frame(width: CGFloat(Double(appSettings.width)*appSettings.gifSize), height: CGFloat(Double(appSettings.height)*appSettings.gifSize))
                    }
                    Spacer()
                }
            }.frame(width: CGFloat(appSettings.width), height: CGFloat(appSettings.height))
                .cornerRadius(appSettings.roundedCorners ? 20 : 0)
                .clipped()
        }
    }
}
