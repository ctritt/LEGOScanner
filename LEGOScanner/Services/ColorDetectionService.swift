//  ColorDetectionService.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import UIKit
import Vision

class ColorDetectionService {
    static let shared = ColorDetectionService()
    
    // LEGO Official Color Palette
    struct LegoColor {
        let id: Int16
        let name: String
        let rgb: (r: CGFloat, g: CGFloat, b: CGFloat)
    }
    
    static let legoColors: [LegoColor] = [
        LegoColor(id: 5, name: "Red", rgb: (201/255, 26/255, 9/255)),
        LegoColor(id: 7, name: "Blue", rgb: (0/255, 85/255, 191/255)),
        LegoColor(id: 14, name: "Yellow", rgb: (255/255, 205/255, 3/255)),
        LegoColor(id: 10, name: "Green", rgb: (75/255, 151/255, 74/255)),
        LegoColor(id: 11, name: "Black", rgb: (33/255, 33/255, 33/255)),
        LegoColor(id: 15, name: "White", rgb: (255/255, 255/255, 255/255)),
        LegoColor(id: 9, name: "Light Gray", rgb: (161/255, 165/255, 162/255)),
        LegoColor(id: 85, name: "Dark Bluish Gray", rgb: (99/255, 95/255, 97/255)),
        LegoColor(id: 4, name: "Orange", rgb: (252/255, 94/255, 2/255)),
        LegoColor(id: 8, name: "Brown", rgb: (91/255, 49/255, 35/255)),
        LegoColor(id: 28, name: "Dark Green", rgb: (0/255, 69/255, 26/255)),
        LegoColor(id: 2, name: "Tan", rgb: (222/255, 198/255, 156/255)),
        LegoColor(id: 23, name: "Pink", rgb: (255/255, 158/255, 205/255)),
        LegoColor(id: 24, name: "Purple", rgb: (129/255, 0/255, 123/255)),
        LegoColor(id: 34, name: "Lime", rgb: (163/255, 195/255, 0/255)),
        LegoColor(id: 321, name: "Dark Azure", rgb: (0/255, 143/255, 185/255))
    ]
    
    func detectDominantColor(in image: UIImage) -> LegoColor {
        guard let cgImage = image.cgImage else {
            return ColorDetectionService.legoColors[0]
        }
        // Sample center region of image
        let width = cgImage.width
        let height = cgImage.height
        let centerX = width / 2
        let centerY = height / 2
        let sampleSize = min(width, height) / 4
        let rect = CGRect(
            x: centerX - sampleSize / 2,
            y: centerY - sampleSize / 2,
            width: sampleSize,
            height: sampleSize
        )
        guard let croppedImage = cgImage.cropping(to: rect) else {
            return ColorDetectionService.legoColors[0]
        }
        let averageColor = getAverageColor(from: croppedImage)
        return findClosestLegoColor(to: averageColor)
    }
    
    private func getAverageColor(from cgImage: CGImage) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var count: CGFloat = 0
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * bytesPerPixel
                let r = CGFloat(pixelData[offset]) / 255.0
                let g = CGFloat(pixelData[offset + 1]) / 255.0
                let b = CGFloat(pixelData[offset + 2]) / 255.0
                totalR += r
                totalG += g
                totalB += b
                count += 1
            }
        }
        return (totalR / count, totalG / count, totalB / count)
    }
    
    private func findClosestLegoColor(to rgb: (r: CGFloat, g: CGFloat, b: CGFloat)) -> LegoColor {
        var minDistance = CGFloat.infinity
        var closestColor = ColorDetectionService.legoColors[0]
        for legoColor in ColorDetectionService.legoColors {
            let distance = colorDistance(rgb, legoColor.rgb)
            if distance < minDistance {
                minDistance = distance
                closestColor = legoColor
            }
        }
        return closestColor
    }
    
    private func colorDistance(_ color1: (r: CGFloat, g: CGFloat, b: CGFloat), _ color2: (r: CGFloat, g: CGFloat, b: CGFloat)) -> CGFloat {
        let rDiff = color1.r - color2.r
        let gDiff = color1.g - color2.g
        let bDiff = color1.b - color2.b
        return sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
    }
}
