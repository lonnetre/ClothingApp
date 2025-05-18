//
//  SecondStepView.swift
//  ClothingApp
//
//  Created by yehor on 30.04.25.
//

import SwiftUI

// TODO: make all the sizes dynamic
struct SecondStepView: View {
    // MARK: - Properties
    @State private var animationPhase: AnimationPhase = .initial
    @State private var isSuccessState = false
    var onComplete: () -> Void = {}  // default empty
    
    // Animation durations
    private let durations = (
        raise: 1.5,
        appear: 1.0,
        complete: 0.5,
        transition: 0.7
    )
    
    // Computed properties for animation states
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
                        .frame(width: 210, height: 400)
                        .background(
                            Color(.systemBackground)
                            .cornerRadius(30)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Screen content: T-shirt and scanning elements
                    ZStack {
                        // T-shirt image changes based on state
                        if isSuccessState {
                            Image("tshirt-full")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .opacity(tshirtOpacity)
                                .transition(.opacity)
                        } else {
                            Image("tshirt-not-full")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .opacity(tshirtOpacity)
                                .transition(.opacity)
                        }
                        
                        // Recognition overlay changes based on state
                        if animationPhase != .initial && animationPhase != .phoneRaised {
                            if isSuccessState {
                                successOverlay
                                    .transition(.opacity)
                            } else {
                                errorOverlay
                                    .transition(.opacity)
                            }
                        }
                    }
                    .animation(.easeInOut(duration: durations.transition), value: isSuccessState)
                }
                .animation(.spring(response: 0, dampingFraction: 0.7), value: animationPhase)
                
                Spacer()
            }
        }
        .onAppear(perform: startAnimationSequence)
    }
    
    // MARK: - Components
    
    private var errorOverlay: some View {
        ZStack {
            // Corner brackets
            VStack {
                HStack {
                    bracket(color: .red)
                    Spacer()
                    bracket(color: .red).rotation3DEffect(.degrees(90), axis: (x: 0, y: 0, z: 1))
                }
                Spacer()
                HStack {
                    bracket(color: .red).rotation3DEffect(.degrees(-90), axis: (x: 0, y: 0, z: 1))
                    Spacer()
                    bracket(color: .red).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                }
            }
            .frame(width: 175, height: 175)
            
            Spacer()
            
            // Status label
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.red)
                .padding(.top, 200)
                .offset(y: 30)
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            // Corner brackets
            VStack {
                HStack {
                    bracket(color: .green)
                    Spacer()
                    bracket(color: .green).rotation3DEffect(.degrees(90), axis: (x: 0, y: 0, z: 1))
                }
                Spacer()
                HStack {
                    bracket(color: .green).rotation3DEffect(.degrees(-90), axis: (x: 0, y: 0, z: 1))
                    Spacer()
                    bracket(color: .green).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                }
            }
            .frame(width: 175, height: 175)
            
            Spacer()
            
            // Status label
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.green)
                .padding(.top, 200)
                .offset(y: 30)
        }
    }
    
    private func bracket(color: Color) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 30))
            path.addLine(to: CGPoint(x: 0, y: 10))
            path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 30, y: 0))
        }
        .stroke(color, lineWidth: 4)
        .frame(width: 30, height: 30)
    }
    
    // MARK: - Animation Logic
    
    private func startAnimationSequence() {
        runDelayed(0.5) {
            animationPhase = .phoneRaised
            
            animationPhase = .tshirtVisible
            
            // After 3 seconds, transition from error state to success state
            runDelayed(3.0) {
                withAnimation(.easeInOut(duration: durations.transition)) {
                    isSuccessState = true
                }
                
                // Call onComplete after showing the success state
                runDelayed(1.0) {
                    animationPhase = .complete
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
struct SecondStepView_Previews: PreviewProvider {
    static var previews: some View {
        SecondStepView()
    }
}
