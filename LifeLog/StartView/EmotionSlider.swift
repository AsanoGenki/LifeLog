//
//  LockerSlider.swift
//  LifeLog
//
//  Created by Genki on 12/3/23.
//

import SwiftUI

struct EmotionSlider<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    @Binding private var value: V
    private let bounds: ClosedRange<V>
    private let step: V.Stride
    private let length: CGFloat = 36
    private let lineWidth: CGFloat = 0
    @State private var ratio: CGFloat   = 0
    @State private var startX: CGFloat?
    // MARK: - Initializer
    init(value: Binding<V>, in bounds: ClosedRange<V>, step: V.Stride = 1) {
        _value  = value
        self.bounds = bounds
        self.step   = step
    }
    // MARK: - View
    // MARK: Public
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: length / 2)
                        .foregroundColor(Color.gray.opacity(0.25))
                    // Thumb
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: length, height: length)
                        .offset(x: (proxy.size.width - length) * ratio)
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged({ updateStatus(value: $0, proxy: proxy) })
                            .onEnded { _ in startX = nil })
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)
                }
                .frame(height: length)
                .overlay(overlay)
                .simultaneousGesture(DragGesture(minimumDistance: 0)
                    .onChanged({ update(value: $0, proxy: proxy) }))
                .onAppear {
                    ratio = min(1, max(0, CGFloat(value / bounds.upperBound)))
                }
                .onChange(of: value) { value in
                    ratio = min(1, max(0, CGFloat(value / bounds.upperBound)))
                }
            }
        }
    }
    // MARK: Private
    private var overlay: some View {
        RoundedRectangle(cornerRadius: (length + lineWidth) / 2)
            .stroke(Color.gray, lineWidth: lineWidth)
            .frame(height: length + lineWidth)
    }
    // MARK: - Function
    // MARK: Private
    private func updateStatus(value: DragGesture.Value, proxy: GeometryProxy) {
        guard startX == nil else { return }
        let delta = value.startLocation.x - (proxy.size.width - length) * ratio
        startX = (length < value.startLocation.x && 0 < delta) ? delta : value.startLocation.x
    }
    private func update(value: DragGesture.Value, proxy: GeometryProxy) {
        guard let xLocation = startX else { return }
        startX = min(length, max(0, xLocation))
        var point = value.location.x - xLocation
        let delta = proxy.size.width - length
        // Check the boundary
        if point < 0 {
            startX = value.location.x
            point = 0
        } else if delta < point {
            startX = value.location.x - delta
            point = delta
        }
        // Ratio
        var ratio = point / delta
        // Step
        if step != 1 {
            let unit = CGFloat(step) / CGFloat(bounds.upperBound)
            let remainder = ratio.remainder(dividingBy: unit)
            if remainder != 0 {
                ratio -= CGFloat(remainder)
            }
        }
        self.ratio = ratio
        self.value = V(bounds.upperBound) * V(ratio)
    }
}

func returnFullfilment(fullfilment: Int) -> LocalizedStringKey {
    if fullfilment < 20 {
        return LocalizedStringKey("Very Dissatisfied")
    } else if 20 <= fullfilment && fullfilment < 40 {
        return LocalizedStringKey("Dissatisfied")
    } else if 40 <= fullfilment && fullfilment < 60 {
        return LocalizedStringKey("Neutral")
    } else if 60 <= fullfilment && fullfilment < 80 {
        return LocalizedStringKey("Satisfied")
    } else {
        return LocalizedStringKey("Very Satisfied")
    }
}
