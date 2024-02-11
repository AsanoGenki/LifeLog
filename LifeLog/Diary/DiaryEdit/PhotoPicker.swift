//
//  ImagePicker.swift
//  LifeLog
//
//  Created by Genki on 11/18/23.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    @Binding var photos: [UIImage]
    var selectionLimit: Int
    var filter: PHPickerFilter?
    var itemProviders: [NSItemProvider] = []
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = self.selectionLimit
        configuration.filter = self.filter
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    func makeCoordinator() -> Coordinator {
        return PhotoPicker.Coordinator(parent: self)
    }
    class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
        var parent: PhotoPicker
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            if !results.isEmpty {
                parent.itemProviders = []
            }
            parent.itemProviders = results.map(\.itemProvider)
            loadImage()
        }
        private func loadImage() {
            for itemProvider in parent.itemProviders where itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        let newImages = image
                        let inputImageData = coreDataObjectFromImages(images: [newImages])
                        let addImages = imagesFromCoreData(object: inputImageData)
                        if let images = addImages {
                            for image in images where !self.parent.photos.contains(image) {
                                self.parent.photos.append(image)
                            }
                        }
                    } else {
                        print("Could not load image", error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
}
