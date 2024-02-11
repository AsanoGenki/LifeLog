//
//  ImageView.swift
//  LifeLog
//
//  Created by Genki on 11/18/23.
//

import SwiftUI

struct PhotoDetailView: View {
    @EnvironmentObject var photoPickerViewModel: PhotoPickerViewModel
    @GestureState var draggingOffset: CGSize = .zero
    @Binding var images: [UIImage]
    @State var showAlert = false
    var body: some View {
        ZStack {
            if photoPickerViewModel.showImageViewer {
                Color.black
                    .opacity(photoPickerViewModel.bgOpacity)
                    .ignoresSafeArea()
                ScrollView(.init()) {
                    TabView(selection: $photoPickerViewModel.selectedImageID) {
                        ForEach(0..<images.count, id: \.self) { index in
                            ZoomableImageViewWrapper(uiImage: images[index])
                                        .edgesIgnoringSafeArea(.all)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
                .ignoresSafeArea()
                .transition(.move(edge: .bottom))
                .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("画像を保存しました。"),
                                message: Text(""),
                                dismissButton: .default(Text("OK"), action: {
                                    showAlert = false
                                }))
                          }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            Button(action: {
                withAnimation(.default) {
                    photoPickerViewModel.showImageViewer.toggle()
                }
            }, label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.25))
                    .clipShape(Circle())
            })
            .padding(20)
            .opacity(photoPickerViewModel.showImageViewer ? photoPickerViewModel.bgOpacity : 0)
            , alignment: .topLeading
        )
        .overlay(
            Button {
                withAnimation(.default) {
                        images.remove(at: photoPickerViewModel.selectedImageID)
                    photoPickerViewModel.showImageViewer.toggle()
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.25))
                    .clipShape(Circle())
            }
            .padding(20)
            .opacity(photoPickerViewModel.showImageViewer ? photoPickerViewModel.bgOpacity : 0)
            , alignment: .bottomLeading
        )
        .overlay(
            Button(action: {
                ImageSaver($showAlert).writeToPhotoAlbum(image: images[photoPickerViewModel.selectedImageID])
            }, label: {
                Image(systemName: "arrow.down.to.line.compact")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.25))
                    .clipShape(Circle())
            })
            .padding(20)
            .opacity(photoPickerViewModel.showImageViewer ? photoPickerViewModel.bgOpacity : 0)
            , alignment: .bottomTrailing
        )
        .overlay(
            VStack {
                Spacer()
                Text("Successfully saved")
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
                Spacer()
                Divider()
                Spacer()
                Button {
                    showAlert = false
                } label: {
                    HStack {
                        Spacer()
                        Text("OK")
                        Spacer()
                    }
                }
                Spacer()
            }
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 100)
                .frame(maxWidth: 240)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(showAlert ? 1 : 0)
            , alignment: .center
        )
        .gesture(DragGesture().updating($draggingOffset, body: { (value, outValue, _) in
            outValue = value.translation
            onChange(value: draggingOffset)
        }).onEnded(onEnd(value:)))
    }
    func onEnd(value: DragGesture.Value) {
        withAnimation(.easeInOut) {
            var translation = value.translation.height
            if translation < 0 {
                translation = -translation
            }
            if translation < 150 {
                photoPickerViewModel.imageViewerOffset = .zero
                photoPickerViewModel.bgOpacity = 1
            } else {
                    photoPickerViewModel.showImageViewer.toggle()
                    photoPickerViewModel.imageViewerOffset = .zero
                    photoPickerViewModel.bgOpacity = 1
            }
        }
    }
    func onChange(value: CGSize) {
        photoPickerViewModel.imageViewerOffset = value
        let halgHeight = UIScreen.main.bounds.height / 2
        let progress = photoPickerViewModel.imageViewerOffset.height / halgHeight
        withAnimation(.default) {
            photoPickerViewModel.bgOpacity = Double(1 - (progress < 0 ? -progress : progress))
        }
    }
}

class ImageSaver: NSObject {
    @Binding var showAlert: Bool
    init(_ showAlert: Binding<Bool>) {
        _showAlert = showAlert
    }
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage), nil)
    }
    @objc func didFinishSavingImage(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if error != nil {
            print("保存に失敗しました。")
        } else {
            showAlert = true
        }
    }
}
