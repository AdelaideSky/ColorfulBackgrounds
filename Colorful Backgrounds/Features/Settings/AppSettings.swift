//
//  AppSettings.swift
//  Colorful Backgrounds
//
//  Created by Adélaïde Sky on 01/07/2023.
//

import Foundation
import SwiftUI
import SkyKit_Design
import GIFImage

class AppSettings: ObservableObject {
    
    static var shared: AppSettings = .init()
        
    @AppStorage("fr.adesky.colorfulBackgrounds.roundedCorners") var roundedCorners: Bool = true
    @AppStorage("fr.adesky.colorfulBackgrounds.height") var height: Int = 532
    @AppStorage("fr.adesky.colorfulBackgrounds.width") var width: Int = 1600
    @AppStorage("fr.adesky.colorfulBackgrounds.gifSpeed") var gifSpeed: Double = 1.2
    @AppStorage("fr.adesky.colorfulBackgrounds.gifSize") var gifSize: Double = 0.7
    @AppStorage("fr.adesky.colorfulBackgrounds.noiseAmount") var noiseAmount: Double = 0.05
    
    
    @Published var gif: GIFImage? = nil
    @Published var gifFrames: [NSImage]? = nil
    
    @Published var noiseTexture: NSImage? = nil
    
    @Published var titleText: String = ""
    @Published var subtitleText: String = ""
    
    @Published var gifExportProgress: Double = 100.0
    @Published var showExportSheet = false
    @Published var isExporting = false
    
    init() {
        SKNoiseGenerator().image(width: width, height: height) { self.noiseTexture = $0 }
    }
}
