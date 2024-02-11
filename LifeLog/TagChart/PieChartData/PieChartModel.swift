//
//  PieChartModel.swift
//  LifeLog
//
//  Created by Genki on 2/9/24.
//

import SwiftUI

struct PieChartModel {
    @AppStorage("pieChartDate") var pieChartDate = Date()
    @AppStorage("pieChartDateTab") var pieChartDateTab: DateTab = .day
    var eventListSort: EventListSort = .recently
    var filterTag: UUID?
    var activePieChartIndex: Int = -1
    var swipeDirection: SwipeDirection = .none
    mutating func changeDateTab(dateTab: DateTab) {
        pieChartDateTab = dateTab
    }
    mutating func changeActivePieChartIndex(index: Int) {
        activePieChartIndex = index
    }
    mutating func changeFilterTag(uuid: UUID?) {
        filterTag = uuid
    }
    mutating func changeEventListSort(sort: EventListSort) {
        eventListSort = sort
    }
    mutating func changeSwipeDirection(inputSwipeDirection: SwipeDirection) {
        swipeDirection = inputSwipeDirection
    }
    mutating func handleSwipeLeft() {
        if pieChartDateTab == .day {
            if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: pieChartDate) {
                pieChartDate = newDate
            }
        } else if pieChartDateTab == .week {
            if let newDate = Calendar.current.date(byAdding: .day, value: -7, to: pieChartDate) {
                pieChartDate = newDate
            }
        } else if pieChartDateTab == .month {
            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: pieChartDate) {
                pieChartDate = newDate
            }
        } else {
            if let newDate = Calendar.current.date(byAdding: .month, value: -6, to: pieChartDate) {
                pieChartDate = newDate
            }
        }
        updateTodayState()
    }
    mutating func handleSwipeRight() {
        if pieChartDateTab == .day {
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: pieChartDate) {
                pieChartDate = newDate
            }
        } else if pieChartDateTab == .week {
            if let newDate = Calendar.current.date(byAdding: .day, value: +7, to: pieChartDate) {
                pieChartDate = newDate
            }
        } else if pieChartDateTab == .month {
            if let newDate = Calendar.current.date(byAdding: .month, value: +1, to: pieChartDate) {
                pieChartDate = newDate
            }
        } else {
            if let newDate = Calendar.current.date(byAdding: .month, value: +6, to: pieChartDate) {
                pieChartDate = newDate
            }
        }
        updateTodayState()
    }
    mutating func updateTodayState() {
        let result = Calendar.current.compare(pieChartDate, to: Date(), toGranularity: .day)
        if result == .orderedSame {
            swipeDirection = .none
        } else if pieChartDate < Date() {
            swipeDirection = .left
        } else {
            swipeDirection = .right
        }
    }
}

struct PieSliceData: Identifiable, Hashable {
    var id = UUID()
    var startAngle: Angle
    var endAngle: Angle
    var text: String
    var color: Color
    var percentage: Double
}
struct CalendarTypeSum: Identifiable, Hashable {
    var id = UUID()
    var tag: EventTag
    var totalDuration: TimeInterval
}
