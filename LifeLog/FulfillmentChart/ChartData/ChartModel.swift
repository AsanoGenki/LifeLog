//
//  ChartModel.swift
//  LifeLog
//
//  Created by Genki on 2/9/24.
//

import SwiftUI

struct ChartModel {
    @AppStorage("displayDate") var displayDate = Date()
    @AppStorage("chartDateTab") var chartDateTab: DateTab = .day
    var eventListSort: EventListSort = .recently
    var selectedElement: Date?
    var filterTag: UUID?
    var swipeDirection: SwipeDirection = .none
    mutating func displayToday() {
        displayDate = Date()
    }
    mutating func changeDateTab(dateTab: DateTab) {
        chartDateTab = dateTab
    }
    mutating func changeEventListSort(sort: EventListSort) {
        eventListSort = sort
    }
    mutating func handleSwipeLeft() {
        if chartDateTab == .day {
            if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: displayDate) {
                displayDate = newDate
            }
        } else if chartDateTab == .week {
            if let newDate = Calendar.current.date(byAdding: .day, value: -7, to: displayDate) {
                displayDate = newDate
            }
        } else if chartDateTab == .month {
            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: displayDate) {
                displayDate = newDate
            }
        } else {
            if let newDate = Calendar.current.date(byAdding: .month, value: -6, to: displayDate) {
                displayDate = newDate
            }
        }
        selectedElement = nil
        updateTodayState()
    }
    mutating func handleSwipeRight() {
        if chartDateTab == .day {
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: displayDate) {
                displayDate = newDate
            }
        } else if chartDateTab == .week {
            if let newDate = Calendar.current.date(byAdding: .day, value: +7, to: displayDate) {
                displayDate = newDate
            }
        } else if chartDateTab == .month {
            if let newDate = Calendar.current.date(byAdding: .month, value: +1, to: displayDate) {
                displayDate = newDate
            }
        } else {
            if let newDate = Calendar.current.date(byAdding: .month, value: +6, to: displayDate) {
                displayDate = newDate
            }
        }
        selectedElement = nil
        updateTodayState()
    }
    mutating func updateTodayState() {
        let result = Calendar.current.compare(displayDate, to: Date(), toGranularity: .day)
        if result == .orderedSame {
            swipeDirection = .none
        } else if displayDate < Date() {
            swipeDirection = .left
        } else {
            swipeDirection = .right
        }
    }
    mutating func changeSwipeDirection(inputSwipeDirection: SwipeDirection) {
        swipeDirection = inputSwipeDirection
    }
}

enum DateTab: String, CaseIterable {
    case day, week, month, sixMonth
    var text: String {
        switch self {
        case .day:
            return "D"
        case .week:
            return "W"
        case .month:
            return "M"
        case .sixMonth:
            return "6M"
        }
    }
}
enum EventListSort {
    case recently, old, high, low
    var text: String {
        switch self {
        case .recently:
            return "Recently"
        case .old:
            return "Old"
        case .high:
            return "High Fulfillment"
        case .low:
            return "Low Fulfillment"
        }
    }
}
enum SwipeDirection {
    case none
    case left
    case right
}
