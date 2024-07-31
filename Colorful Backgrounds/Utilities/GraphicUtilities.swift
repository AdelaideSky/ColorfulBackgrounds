//
//  GraphicUtilities.swift
//  Colorful Backgrounds
//
//  Created by Adélaïde Sky on 08/03/2023.
//

import Foundation
import GIFImage
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

func overlayImage(background: NSImage, overlay: NSImage, overlaySizeRatio: Double) throws -> CGImage {
    let newImage = NSImage(size: background.size)
    newImage.lockFocus()

    let size = min(background.size.width, background.size.height) * overlaySizeRatio
    let overlayRect = CGRect(x: (background.size.width - size) / 2, y: (background.size.height - size) / 2, width: size, height: size)

    background.draw(at: .zero, from: .zero, operation: .sourceOver, fraction: 1.0)
    overlay.draw(in: overlayRect)

    newImage.unlockFocus()
    guard let cgImage = newImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        throw NSError(domain: "GraphicUtilitiesError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to create CGImage from NSImage."])
    }
    return cgImage
}

extension NSImage {
    func pngData(size: CGSize, imageInterpolation: NSImageInterpolation = .medium) -> Data? {
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bitmapFormat: [.alphaFirst, .alphaNonpremultiplied], bytesPerRow: 0, bitsPerPixel: 0) else {
            return nil
        }

        bitmap.size = size
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current?.imageInterpolation = imageInterpolation
        draw(in: CGRect(origin: .zero, size: size))
        NSGraphicsContext.restoreGraphicsState()

        return bitmap.representation(using: .png, properties: [:])
    }

    func saveAsPNG(to url: URL) {
        guard let tiffData = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffData) else { return }
        guard let pngData = bitmapImage.representation(using: .png, properties: [:]) else { return }
        try? pngData.write(to: url)
    }
}

func animatedGif(from images: [CGImage], to fileUrl: URL, speed: Double) {
    let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]] as CFDictionary
    let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: speed]] as CFDictionary

    guard let destination = CGImageDestinationCreateWithURL(fileUrl as CFURL, UTType.gif.identifier as CFString, images.count, nil) else {
        print("Failed to create image destination")
        return
    }

    CGImageDestinationSetProperties(destination, fileProperties)
    for image in images {
        CGImageDestinationAddImage(destination, image, frameProperties)
    }

    if !CGImageDestinationFinalize(destination) {
        print("Failed to finalize the image destination")
    }
}

extension NSImage {
    var cgImage: CGImage? {
        guard let imageData = tiffRepresentation, let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}

extension Data {
    func gifFrames() -> [NSImage]? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil), CGImageSourceGetCount(source) > 0 else { return nil }

        return (0 ..< CGImageSourceGetCount(source)).compactMap { index in
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { return nil }
            let image = NSImage(size: CGSize(width: cgImage.width, height: cgImage.height))
            image.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
            return image
        }
    }
}

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}
