//
//  ChartViewModel.swift
//  LifeLog
//
//  Created by Genki on 2/9/24.
//

import SwiftUI

class ChartViewModel: ObservableObject {
    @Published var model: ChartModel = ChartModel()
    var selectedElement: Date? {
        model.selectedElement
    }
    var selectedDateTab: DateTab {
        model.chartDateTab
    }
    var eventListSort: EventListSort {
        model.eventListSort
    }
    var swipeDirection: SwipeDirection {
        model.swipeDirection
    }
    var filterTag: UUID? {
        model.filterTag
    }
    func displayToday() {
        model.displayToday()
    }
    func changeDateTab(dateTab: DateTab) {
        model.changeDateTab(dateTab: dateTab)
    }
    func changeEventListSort(sort: EventListSort) {
        model.changeEventListSort(sort: sort)
    }
    func handleGesture(value: DragGesture.Value) {
        if value.predictedEndTranslation.width > 0 {
            model.handleSwipeLeft()
        } else {
            model.handleSwipeRight()
        }
    }
    func handleSwipeLeft() {
        model.handleSwipeLeft()
    }
    func handleSwipeRight() {
        model.handleSwipeRight()
    }
    func changeSwipeDirection(inputSwipeDirection: SwipeDirection) {
        model.changeSwipeDirection(inputSwipeDirection: inputSwipeDirection)
    }
}
