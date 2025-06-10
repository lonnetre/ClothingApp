//
//  CutoutView.swift
//  ClothingApp
//
//  Created by yehor on 03.05.25.
//

import SwiftUI

struct CutoutView: View {

    @Binding var image: UIImage
    @Binding var cutout: UIImage?
    @State private var spoilerViewOpacity: Double = 0
    @State private var cutoutScale: Double = 1

    private let animation: Animation = .easeOut(duration: 1)

    var body: some View {
        ZStack {
            // Fullscreen SpoilerView in the background
            SpoilerView(isOn: true)
                .ignoresSafeArea()
                .opacity(spoilerViewOpacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            originalImage
            cutoutImage
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var originalImage: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .opacity(cutout == nil ? 1 : 0)
            .animation(animation, value: cutout)
    }

    @ViewBuilder
    private var cutoutImage: some View {
        if let cutout {
            Image(uiImage: cutout)
                .resizable()
                .scaledToFit()
                .scaleEffect(cutoutScale)
                .onAppear {
                    withAnimation(animation) {
                        spoilerViewOpacity = 1
                        cutoutScale = 1.1
                    } completion: {
                        withAnimation(.linear) {
                            spoilerViewOpacity = 0
                        }
                        withAnimation(animation) {
                            cutoutScale = 1
                        }
                    }
                }
        }
    }
}

#Preview {
    CutoutView(image: .constant(.appleTest), cutout: .constant(nil))
}
