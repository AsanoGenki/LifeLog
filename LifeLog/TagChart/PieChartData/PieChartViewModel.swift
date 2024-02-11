//
//  PieChartViewModel.swift
//  LifeLog
//
//  Created by Genki on 2/9/24.
//

import SwiftUI

class PieChartViewModel: ObservableObject {
    @Published var model: PieChartModel = PieChartModel()
    var eventListSort: EventListSort {
        model.eventListSort
    }
    var chartDateTab: DateTab {
        model.pieChartDateTab
    }
    var activePieChartIndex: Int {
        model.activePieChartIndex
    }
    var filterTag: UUID? {
        model.filterTag
    }
    var swipeDirection: SwipeDirection {
        model.swipeDirection
    }
    func changeDateTab(dateTab: DateTab) {
        model.changeDateTab(dateTab: dateTab)
    }
    func changeEventListSort(sort: EventListSort) {
        model.changeEventListSort(sort: sort)
    }
    func changeActivePieChartIndex(index: Int) {
        model.changeActivePieChartIndex(index: index)
    }
    func changeFilterTag(uuid: UUID?) {
        model.changeFilterTag(uuid: uuid)
    }
    func changeSwipeDirection(inputSwipeDirection: SwipeDirection) {
        model.changeSwipeDirection(inputSwipeDirection: inputSwipeDirection)
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
}
