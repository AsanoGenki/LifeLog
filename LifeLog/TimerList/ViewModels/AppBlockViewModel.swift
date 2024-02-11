//
//  AppBlockViewModel.swift
//  LifeLog
//
//  Created by Genki on 1/23/24.
//

import SwiftUI
import FamilyControls

class AppBlockViewModel: ObservableObject {
    @AppStorage("blockAppSelecton") var blockAppSelecton = FamilyActivitySelection()
    var model: AppBlockModel = AppBlockModel()
    func blockApp() {
        model.blockApp()
    }
    func unBlockApp() {
        model.unBlockApp()
    }
    func denyAppRemoval() {
        model.denyAppRemoval()
    }
    func undenyAppRemoval() {
        model.undenyAppRemoval()
    }
}
