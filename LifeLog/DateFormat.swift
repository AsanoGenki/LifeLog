//
//  DateFormat.swift
//  LifeLog
//
//  Created by Genki on 12/22/23.
//

import SwiftUI

func weekDayToYear(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    if Locale.current.language.languageCode?.identifier == "ja" {
        dateFormatter.dateFormat = "yyyy年MMMd日(EEE)"
    } else {
        dateFormatter.dateFormat = "E, MMM d, yyyy"
    }
    return dateFormatter.string(from: date)
}
func weekDayToMonth(date: Date) -> String {
    let dateFormatter = DateFormatter()
    if Locale.current.language.languageCode?.identifier == "ja" {
        dateFormatter.dateFormat = "MMMdd日(E)"
    } else {
        dateFormatter.dateFormat = "E, MMM dd"
    }
    return dateFormatter.string(from: date)
}
func dayToYear(date: Date) -> String {
    let formatter = DateFormatter()
    if Locale.current.language.languageCode?.identifier == "ja" {
        formatter.setLocalizedDateFormatFromTemplate("yyyy年MMMd日")
    } else {
        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
    }
    return formatter.string(from: date)
}
func monthToYear(date: Date) -> String {
    let formatter = DateFormatter()
    if Locale.current.language.languageCode?.identifier == "ja" {
        formatter.setLocalizedDateFormatFromTemplate("yyyy年MMM")
    } else {
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
    }
    return formatter.string(from: date)
}
func timeString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
}
func eventItemDate(startDate: Date, endDate: Date) -> String {
    let dateFormatter = DateFormatter()
    if Locale.current.language.languageCode?.identifier == "ja" {
        dateFormatter.dateFormat = "MMMd日 HH:mm"
    } else {
        dateFormatter.dateFormat = "MMM d, HH:mm"
    }
    let startOfWeekString = dateFormatter.string(from: startDate)
    let endOfWeekString = dateFormatter.string(from: endDate)
    if Locale.current.language.languageCode?.identifier == "ja" {
        return "\(startOfWeekString) ~ \(endOfWeekString)"
    } else {
        return "\(startOfWeekString) - \(endOfWeekString)"
    }
}
