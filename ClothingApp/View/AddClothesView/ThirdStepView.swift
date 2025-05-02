//
//  ThirdStepView.swift
//  ClothingApp
//
//  Created by yehor on 02.05.25.
//

import SwiftUI

// TODO: make all the sizes dynamic
struct ThirdStepView: View {
    // MARK: - Properties
    @State private var animationPhase: AnimationPhase = .initial
    @State private var isAnimationFinished = false
    var onComplete: () -> Void = {}  // default empty
    var widthOfTheScreen = 210
    
    // Animation durations
    private let durations = (
        raise: 1.5,
        appear: 1.0,
        complete: 0.5,
        transition: 0.7
    )
    
    // Computed properties for animation states
    private var phoneRotation: Double { animationPhase == .initial ? 90 : 0 }
    private var phoneOffset: CGFloat { animationPhase == .initial ? 100 : 0 }
    private var tshirtOpacity: Double {
        animationPhase == .initial || animationPhase == .phoneRaised ? 0 : 1
    }
    
    var body: some View {
        ZStack {
            // Phone and content
            VStack {
                Spacer()
                
                ZStack {
                    // Phone frame with gray background
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.gray, lineWidth: 8)
                        .frame(width: CGFloat(widthOfTheScreen), height: 400)
                        .background(
                            Color(.systemBackground)
                            .cornerRadius(30)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Screen content: T-shirt
                    ZStack {
                        Image("tshirt-full")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .opacity(tshirtOpacity)
                            .transition(.opacity)
                            .offset(y: -50)
                        
                        HStack (spacing: 12){
                            ForEach(0..<5, id: \.self) {index in
                                Capsule()
                                    .fill(isAnimationFinished
                                           ? (index == 3 ? Color.gray.opacity(0.9) : Color.gray.opacity(0.3))
                                           : Color.gray.opacity(0.3))
                                    .frame(width: (CGFloat(widthOfTheScreen) - (5*8)) / 5, height: 15)
                                .opacity(tshirtOpacity)
                            }
                        }
                        .padding(.top, 150)
                        
                        HStack (spacing: 12){
                            ForEach(0..<7, id: \.self) {index in
                                Circle()
                                    .fill(isAnimationFinished
                                           ? (index == 5 ? Color.gray.opacity(0.9) : Color.gray.opacity(0.3))
                                           : Color.gray.opacity(0.3))
                                    .frame(width: (CGFloat(widthOfTheScreen) - (7*8)) / 7, height: 15)
                                    .opacity(tshirtOpacity)
                            }
                        }
                        .padding(.top, 200)
                        
                        HStack (spacing: 12){
                            ForEach(0..<5, id: \.self) {index in
                                Rectangle()
                                    .fill(isAnimationFinished
                                           ? (index == 2 ? Color.gray.opacity(0.9) : Color.gray.opacity(0.3))
                                           : Color.gray.opacity(0.3))
                                    .frame(width: (CGFloat(widthOfTheScreen) - (5*8)) / 5, height: 30)
                                    .cornerRadius(5)
                                    .opacity(tshirtOpacity)
                            }
                        }
                        .padding(.top, 265)
                    }
                    .animation(.easeInOut(duration: durations.transition), value: isAnimationFinished)
                }
                // rotation for the phone
                .rotation3DEffect(
                    .degrees(phoneRotation),
                    axis: (x: 1.0, y: 0.0, z: 0.0),
                    perspective: 0.3
                )
                .offset(y: phoneOffset)
                .animation(.spring(response: durations.raise, dampingFraction: 0.7), value: animationPhase)
                
                Spacer()
            }
        }
        .onAppear(perform: startAnimationSequence)
    }
    
    // MARK: - Animation Logic
    
    private func startAnimationSequence() {
        runDelayed(0.5) {
            animationPhase = .phoneRaised
            
            runDelayed(durations.raise) {
                animationPhase = .tshirtVisible
                
                // Call onComplete after showing the success state
                runDelayed(1.0) {
                    animationPhase = .complete
                    isAnimationFinished = true
                    onComplete()
                }
            }
        }
    }
    
    private func runDelayed(_ delay: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    }
    
    // MARK: - Types
    enum AnimationPhase {
        case initial, phoneRaised, tshirtVisible, complete
    }
}

// MARK: - Preview
struct ThirdStepView_Previews: PreviewProvider {
    static var previews: some View {
        ThirdStepView()
    }
}
