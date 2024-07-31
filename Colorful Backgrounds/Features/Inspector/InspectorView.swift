//
//  InspectorView.swift
//  Colorful Backgrounds
//
//  Created by Adélaïde Sky on 01/07/2023.
//

import DominantColor
import SkyKit_Design
import SwiftUI

struct InspectorView: View {
    @ObservedObject var appSettings = AppSettings.shared
    @ObservedObject var colors: SKColorMind = .shared

    var body: some View {
        Form {
            colorModelSection
            backgroundSection
            textSection
            gifSection
        }
    }

    private var colorModelSection: some View {
        Section {
            Picker("Model", selection: $colors.model) {
                ForEach(colors.models, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            Button("Shuffle") { colors.shufflePalette() }
        } header: {
            HStack {
                Text("Colors")
                Spacer()
                regenerateButton
            }
        }
    }

    private var backgroundSection: some View {
        Section("Background") {
            TextField("Width", value: $appSettings.width, formatter: NumberFormatter())
                .onChange(of: appSettings.width) { _, _ in
                    updateNoiseTexture()
                }
            TextField("Height", value: $appSettings.height, formatter: NumberFormatter())
                .onChange(of: appSettings.height) { _, _ in
                    updateNoiseTexture()
                }
            Toggle("Rounded Corners", isOn: $appSettings.roundedCorners)
            Slider(value: $appSettings.noiseAmount, in: 0...0.15, label: {
                Label("Noise amount", systemImage: "circle")
                    .labelStyle(.titleOnly)
            }).controlSize(.small)
        }
    }

    private var textSection: some View {
        Section {
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
        } header: {
            HStack {
                Text("Text")
                Spacer()
                Button(action: clearTextFields, label: {
                    Label("Clear Text", systemImage: "trash")
                        .labelStyle(.iconOnly)
                }).buttonStyle(.gentle)
                    .disabled(appSettings.titleText.isEmpty && appSettings.subtitleText.isEmpty)
            }
        }
    }

    private var gifSection: some View {
        Section {
            Slider(value: $appSettings.gifSize, in: 0.1...1, label: {
                Label("Gif size", systemImage: "circle")
                    .labelStyle(.titleOnly)
            }).controlSize(.small)

            Slider(value: $appSettings.gifSpeed, in: 1...2, label: {
                Label("Frame time", systemImage: "circle")
                    .labelStyle(.titleOnly)
            }).controlSize(.small)
        } header: {
            HStack {
                Text("Gif")
                Spacer()
                Button(action: clearGif, label: {
                    Label("Delete gif", systemImage: "trash")
                        .labelStyle(.iconOnly)
                }).buttonStyle(.gentle)
            }
        }
    }

    private var regenerateButton: some View {
        Group {
            if (appSettings.gifFrames ?? []).isEmpty {
                Button(action: { colors.regenerate() }, label: {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                        .labelStyle(.iconOnly)
                }).buttonStyle(.gentleFlipping)
                    .foregroundStyle(.primary)
            } else {
                Menu(content: {
                    Button("From IA") { colors.regenerate() }
                    Button("From GIF") { regenerateFromGIF() }
                }, label: {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                        .labelStyle(.iconOnly)
                }, primaryAction: { colors.regenerate() })
                    .menuStyle(.borderlessButton)
                    .fixedSize()
            }
        }
    }

    private func updateNoiseTexture() {
        SKNoiseGenerator().image(width: appSettings.width, height: appSettings.height) { image in
            DispatchQueue.main.sync {
                appSettings.noiseTexture = image
            }
        }
    }

    private func clearTextFields() {
        appSettings.titleText = ""
        appSettings.subtitleText = ""
    }

    private func clearGif() {
        appSettings.gif = nil
        appSettings.gifFrames = nil
    }

    private func regenerateFromGIF() {
        var tempColors: [Color] = []
        for color in appSettings.gifFrames![0].dominantColors() {
            tempColors.append(Color(nsColor: color))
        }
        colors.palette = tempColors
    }
}
