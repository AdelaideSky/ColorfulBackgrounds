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

func overlayImage(background: NSImage, overlay: NSImage, overlaySizeRatio: Double) throws -> CGImage {
    
    let newImage = NSImage(size: background.size)
    newImage.lockFocus()

    var newImageRect: CGRect = .zero
    newImageRect.size = newImage.size
    
    
    var overlayImageRect: CGRect = .zero
    var size = min(background.size.width*overlaySizeRatio, background.size.height*overlaySizeRatio)
 
    overlayImageRect.size = .init(width: size, height: size)
    overlayImageRect.origin = .init(x: (background.size.width-size)/2, y: (background.size.height-size)/2)
    background.draw(in: newImageRect)
    overlay.draw(in: overlayImageRect)

    newImage.unlockFocus()
    
   
    return newImage.CGImage!
}

extension NSImage {
    func pngData(
        size: CGSize,
        imageInterpolation: NSImageInterpolation = .medium
    ) -> Data? {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        pasteboard.setData(self.tiffRepresentation, forType: .tiff)
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bitmapFormat: [.alphaFirst, .alphaNonpremultiplied],
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return nil
        }

        bitmap.size = size
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current?.imageInterpolation = imageInterpolation
        draw(
            in: NSRect(origin: .zero, size: size),
            from: .zero,
            operation: .copy,
            fraction: 1.0
        )
        NSGraphicsContext.restoreGraphicsState()

        
        
        return bitmap.representation(using: .png, properties: [:])
    }
}


func animatedGif(from images: [CGImage], to fileUrl: URL, speed: Double) {
    let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
    let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): speed]] as CFDictionary
    
    
    if let url = fileUrl as CFURL? {
        
        if let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) {
            CGImageDestinationSetProperties(destination, fileProperties)
            for image in images {
                CGImageDestinationAddImage(destination, image, frameProperties)
            }
            if !CGImageDestinationFinalize(destination) {
                print("Failed to finalize the image destination")
            }
            print("Url = \(fileUrl)")
        }
    }
}

extension NSImage {
    @objc var CGImage: CGImage? {
       get {
            guard let imageData = self.tiffRepresentation else { return nil }
            guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
       }
    }
}
extension Data {
    func gifFrames() -> [NSImage]? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(source)
        if frameCount == 0 {
            return nil
        }
        
        var frames: [NSImage] = []
        for i in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            
            let size = CGSize(width: cgImage.width, height: cgImage.height)
            let image = NSImage(size: size)
            image.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
            
            frames.append(image)
        }
        
        return frames
    }
}
func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}
