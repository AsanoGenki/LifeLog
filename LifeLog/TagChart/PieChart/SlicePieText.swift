//
//  SlicePieText.swift
//  LifeLog
//
//  Created by Genki on 2/10/24.
//

import Foundation

final class SlicePieText {
    private let maxLength = 10.0
    func processText(_ text: String) -> String {
        var count = 0.0
        var newText = ""
        for unicodeScalar in text.unicodeScalars {
            if isFullwidth(unicodeScalar: unicodeScalar) {
                count += 2
            } else {
                if isUppercase(unicodeScalar: unicodeScalar) {
                    count += 1.4
                } else {
                    count += 1.2
                }
            }
            if count <= maxLength {
                newText += String(unicodeScalar)
            } else {
                newText += String("...")
                break
            }
        }
        return newText
    }
    func isFullwidth(unicodeScalar: Unicode.Scalar) -> Bool {
        let value = unicodeScalar.value
        return (value >= 0x1100 && value <= 0x115F) ||
        (value >= 0x2E80 && value <= 0x9FFF) ||
        (value >= 0xAC00 && value <= 0xD7AF) ||
        (value >= 0xF900 && value <= 0xFAFF) ||
        (value >= 0xFE10 && value <= 0xFE1F) ||
        (value >= 0xFE30 && value <= 0xFE4F)
    }
    func isUppercase(unicodeScalar: Unicode.Scalar) -> Bool {
           let value = unicodeScalar.value
           return (value >= 65 && value <= 90)
       }
}
