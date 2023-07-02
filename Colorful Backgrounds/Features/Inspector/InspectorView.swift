//
//  InspectorView.swift
//  Colorful Backgrounds
//
//  Created by Adélaïde Sky on 01/07/2023.
//

import SwiftUI
import DominantColor
import SkyKit_Design

struct InspectorView: View {
    @ObservedObject var appSettings = AppSettings.shared
    @ObservedObject var colors: SKColorMind = .shared
        
    var body: some View {
        Form {
            Section(content: {
                Picker("Model", selection: $colors.model) {
                    ForEach(colors.models, id:\.self) { model in
                        Text(model).tag(model)
                    }
                }
                Button("Shuffle") { colors.shufflePalette() }
            }, header: {
                HStack {
                    Text("Colors")
                    Spacer()
                    if (appSettings.gifFrames ?? []).isEmpty {
                        Button(action: { colors.regenerate() }, label: {
                            Label("Regenerate", systemImage: "arrow.clockwise")
                                .labelStyle(.iconOnly)
                        }).buttonStyle(.gentleFlipping)
                            .foregroundStyle(.primary)
                    } else {
                        Menu(content: {
                            Button("From IA") {
                                colors.regenerate()
                            }
                            Button("From GIF") {
                                var tempColors: [Color] = []
                                
                                for color in appSettings.gifFrames![0].dominantColors() {
                                    tempColors.append(Color(nsColor: color))
                                }
                                colors.palette = tempColors
                            }
                        }, label: {
                            Label("Regenerate", systemImage: "arrow.clockwise")
                                .labelStyle(.iconOnly)
                        }, primaryAction: {
                            colors.regenerate()
                        }).menuStyle(.borderlessButton)
                            .fixedSize()
                    }
                }
            })
            Section("Background") {
                TextField("Width", value: $appSettings.width, formatter: NumberFormatter())
                    .onChange(of: appSettings.width) { _,_ in
                        SKNoiseGenerator().image(width: appSettings.width, height: appSettings.height) { image in
                            DispatchQueue.main.sync {
                                appSettings.noiseTexture = image
                            }
                        }
                    }
                TextField("Height", value: $appSettings.height, formatter: NumberFormatter())
                    .onChange(of: appSettings.height) { _,_ in
                        SKNoiseGenerator().image(width: appSettings.width, height: appSettings.height) { image in
                            DispatchQueue.main.sync {
                                appSettings.noiseTexture = image
                            }
                        }
                    }
                Toggle("Rounded Corners", isOn: $appSettings.roundedCorners)
                Slider(value: $appSettings.noiseAmount, in: 0...0.15, label: {
                    Label("Noise amount", systemImage: "circle")
                        .labelStyle(.titleOnly)
                }).controlSize(.small)
            }
            Section(content: {
                TextField("Title", text: $appSettings.titleText)
                VStack {
                    HStack {
                        Label("Subtitle", systemImage: "")
                            .labelStyle(.titleOnly)
                        Spacer()
                    }
                    TextEditor(text: $appSettings.subtitleText)
                        .disabled(appSettings.titleText.isEmpty)
                        .textEditorStyle(.plain)
                }
                
            }, header: {
                HStack {
                    Text("Text")
                    Spacer()
                    Button(action: {
                        appSettings.titleText = ""
                        appSettings.subtitleText = ""
                    }, label: {
                        Label("Delete gif", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }).buttonStyle(.gentle)
                        .disabled(appSettings.titleText.isEmpty && appSettings.subtitleText.isEmpty)
                }
            })
            if !(appSettings.gifFrames ?? []).isEmpty {
                Section(content: {
                    Slider(value: $appSettings.gifSize, in: 0.1...1, label: {
                        Label("Gif size", systemImage: "circle")
                            .labelStyle(.titleOnly)
                    }).controlSize(.small)
                    
                    Slider(value: $appSettings.gifSpeed, in: 1...2, label: {
                        Label("Frame time", systemImage: "circle")
                            .labelStyle(.titleOnly)
                    }).controlSize(.small)
                    
                }, header: {
                    HStack {
                        Text("Gif")
                        Spacer()
                        Button(action: {
                            appSettings.gif = nil
                            appSettings.gifFrames = nil
                        }, label: {
                            Label("Delete gif", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }).buttonStyle(.gentle)
                    }
                })
            }
        }
    }
}
