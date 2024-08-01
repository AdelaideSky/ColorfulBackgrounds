//
//  ContentView.swift
//  ColorfulBackgroundsApp
//
//  Created by Adélaïde Sky on 06/03/2023.
//

import Alamofire
import AppKit
import DominantColor
import GIFImage
import SkyKit_Design
import SwiftUI
import SwiftyJSON

enum ExportGifState: String {
    case none, starting, calculatingFrames, exportFile, done
}

struct ContentView: View {
    @State private var showingInspector = true
    @ObservedObject private var appSettings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        CanvasView()
            .dropDestination(for: Data.self) { items, _ in
                handleDrop(items: items)
            }
            .inspector(isPresented: $showingInspector, content: inspectorContent)
            .toolbar {
                toolbarContent()
            }
    }

    private func handleDrop(items: [Data]) -> Bool {
        guard let item = items.first else { return false }
        appSettings.gif = GIFImage(source: .static(data: item), animate: true, loop: true)
        appSettings.gifFrames = item.gifFrames()
        print(appSettings.gifFrames ?? [])
        return true
    }

    private func inspectorContent() -> some View {
        InspectorView()
            .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
    }

    private func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: handleActionButton, label: actionButtonLabel)
            Button("Toggle inspector", action: { showingInspector.toggle() })
                .labelStyle(.iconOnly)
            Button("Export Image", action: exportImage)
        }
    }

    private func handleActionButton() {
        (appSettings.gifFrames ?? []).isEmpty ? snapshot() : exportGif()
    }

    private func actionButtonLabel() -> some View {
        HStack {
            Label((appSettings.gifFrames ?? []).isEmpty ? "Copy image" : "Copy GIF", systemImage: "")
                .labelStyle(.titleOnly)
            if appSettings.isExporting {
                ProgressView().scaleEffect(0.5)
            }
        }
    }

    private func exportImage() {
        Task {
            appSettings.isExporting = true
            let view = CanvasView().frame(width: CGFloat(appSettings.width), height: CGFloat(appSettings.height))
            let renderer = ImageRenderer(content: view.foregroundStyle(colorScheme == .light ? .black : .white))
            renderer.scale = 2
            defer { appSettings.isExporting = false }
            guard let nsImage = renderer.nsImage else {
                print("Error rendering image")
                return
            }

            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.png]
            savePanel.canCreateDirectories = true
            savePanel.nameFieldStringValue = "ColorfulBackgrounds.png"
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    nsImage.saveAsPNG(to: url)
                }
            }
        }
    }

    private func snapshot() {
        Task {
            appSettings.isExporting = true
            let view = CanvasView().frame(width: CGFloat(appSettings.width), height: CGFloat(appSettings.height))
            let renderer = ImageRenderer(content: view.foregroundStyle(colorScheme == .light ? .black : .white))
            renderer.scale = 2
            defer { appSettings.isExporting = false }
            guard let nsImage = renderer.nsImage else {
                print("Error rendering image")
                return
            }
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([nsImage])
        }
    }

    private func exportGif() {
        Task {
            appSettings.isExporting = true
            defer { appSettings.isExporting = false }
            let frames = (appSettings.gifFrames ?? []).compactMap { frame in
                ImageRenderer(content: CanvasView(frame).foregroundStyle(colorScheme == .light ? .black : .white)).cgImage
            }
            let exportPath = getDocumentsDirectory().appendingPathComponent("ColorfulBackgrounds.gif")
            animatedGif(from: frames, to: exportPath, speed: appSettings.gifSpeed / 100)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(exportPath.path, forType: .fileURL)
        }
    }
}

struct ColorsView: View {
    @Binding var colors: [Color]

    var body: some View {
        VStack {
            if colors.count > 4 {
                ZStack {
                    AngularGradient(colors: colors, center: .center)
                        .saturation(2)
                        .scaleEffect(1.5)
                        .blur(radius: 100)
                    SKNoiseTexture().opacity(0.08)
                }
            }
        }
    }
}
