//
//  PhotoPickerViewModel.swift
//  LifeLog
//
//  Created by Genki on 11/18/23.
//

import SwiftUI

class PhotoPickerViewModel: ObservableObject {
    @Published var showImageViewer = false
    @Published var selectedImageID: Int = 0
    @Published var imageViewerOffset: CGSize = .zero
    @Published var bgOpacity: Double = 1
    @Published var imageScale: CGFloat = 1
}
