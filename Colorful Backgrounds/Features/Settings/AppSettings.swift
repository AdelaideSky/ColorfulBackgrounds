//
//  AppSettings.swift
//  Colorful Backgrounds
//
//  Created by Adélaïde Sky on 01/07/2023.
//

import Foundation
import GIFImage
import SkyKit_Design
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("fr.adesky.colorfulBackgrounds.roundedCorners") var roundedCorners = true
    @AppStorage("fr.adesky.colorfulBackgrounds.height") var height = 532
    @AppStorage("fr.adesky.colorfulBackgrounds.width") var width = 1600
    @AppStorage("fr.adesky.colorfulBackgrounds.gifSpeed") var gifSpeed = 1.2
    @AppStorage("fr.adesky.colorfulBackgrounds.gifSize") var gifSize = 0.7
    @AppStorage("fr.adesky.colorfulBackgrounds.noiseAmount") var noiseAmount = 0.05

    @Published var gif: GIFImage?
    @Published var gifFrames: [NSImage]?
    @Published var noiseTexture: NSImage?
    @Published var titleText = ""
    @Published var subtitleText = ""
    @Published var gifExportProgress = 100.0
    @Published var showExportSheet = false
    @Published var isExporting = false

    init() {
        generateInitialNoiseTexture()
    }

    private func generateInitialNoiseTexture() {
        SKNoiseGenerator().image(width: width, height: height) { [weak self] image in
            self?.noiseTexture = image
        }
    }
}
