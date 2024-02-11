//
//  GlobalFunction.swift
//  LifeLog
//
//  Created by Genki on 2/10/24.
//

import SwiftUI

func convertColorToData(color: Color) -> Data? {
    do {
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: UIColor(color),
            requiringSecureCoding: false
        )
        return data
    } catch {
        print("Error converting color to data: \(error)")
        return nil
    }
}
func convertDataToColor(data: Data) -> Color? {
    do {
        if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
            return Color(color)
        }
    } catch {
        print("Error converting data to color: \(error)")
    }
    return nil
}
