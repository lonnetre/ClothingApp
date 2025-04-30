//
//  TshirtScannerView.swift
//  ClothingApp
//
//  Created by yehor on 29.04.25.
//

import SwiftUI

// TODO: make all the sizes dynamic
struct FirstStepView: View {
    // MARK: - Properties
    @State private var animationPhase: AnimationPhase = .initial
    @State private var scannerPosition: CGFloat = 120
    @State private var scannerOpacity: Double = 0
    @State private var recognitionComplete = false
    var onComplete: () -> Void = {}  // default empty
    
    // Animation durations
    private let durations = (
        raise: 1.5,
        appear: 1.0,
        scan: 1.5,
        complete: 0.5
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
                        .frame(width: 210, height: 400)
                        .background(
                            Group {
                                if recognitionComplete {
                                    Color(.systemBackground)
                                } else {
                                    Image("room")
                                        .resizable()
                                        .opacity(0.3)
                                }
                            }
                            .cornerRadius(30)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Screen content: T-shirt and scanning elements
                    ZStack {
                        // T-shirt
                        Image("tshirt")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .opacity(tshirtOpacity)
                            .animation(.easeIn(duration: durations.appear), value: tshirtOpacity)
                        
                        // Recognition completion
                        if recognitionComplete {
                            recognitionOverlay
                        }
                        
                        // Scanning line
                        scannerLine
                    }
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
    
    // MARK: - Components
    
    private var scannerLine: some View {
        Capsule()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [.cyan, .blue, .cyan]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 170, height: 5)
            .offset(y: scannerPosition)
            .opacity(scannerOpacity)
            .shadow(color: .white.opacity(0.5), radius: 1, y: 1)
    }
    
    private var recognitionOverlay: some View {
        ZStack {
            // Corner brackets
            VStack {
                HStack {
                    bracket
                    Spacer()
                    bracket.rotation3DEffect(.degrees(90), axis: (x: 0, y: 0, z: 1))
                }
                Spacer()
                HStack {
                    bracket.rotation3DEffect(.degrees(-90), axis: (x: 0, y: 0, z: 1))
                    Spacer()
                    bracket.rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                }
            }
            .frame(width: 175, height: 175)
            
            Spacer()
            
            // Status label
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.blue)
                .padding(.top, 200)
                .offset(y: 30)
        }
        .transition(.opacity)
    }
    
    private var bracket: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 30))
            path.addLine(to: CGPoint(x: 0, y: 10))
            path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 30, y: 0))
        }
        .stroke(Color.blue, lineWidth: 4)
        .frame(width: 30, height: 30)
    }
    
    // MARK: - Animation Logic
    
    private func startAnimationSequence() {
        runDelayed(0.5) {
            animationPhase = .phoneRaised
            
            runDelayed(durations.raise) {
                animationPhase = .tshirtVisible
                
                animationPhase = .scanning
                withAnimation(.easeIn(duration: 0.5)) {
                    scannerOpacity = 1
                }
                
                scanProduct()
                
                runDelayed(durations.scan * 2.5) {
                    withAnimation(.easeInOut(duration: durations.complete)) {
                        scannerOpacity = 0
                        recognitionComplete = true
                        onComplete()
                    }
                    animationPhase = .complete
                }
            }
        }
    }
    
    private func scanProduct() {
        withAnimation(.easeInOut(duration: durations.scan)) {
            scannerPosition = 120
        }
        
        runDelayed(durations.scan) {
            withAnimation(.easeInOut(duration: durations.scan)) {
                scannerPosition = -120
            }
            
            if animationPhase == .scanning {
                runDelayed(durations.scan) {
                    scanProduct()
                }
            }
        }
    }
    
    private func runDelayed(_ delay: Double, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    }
    
    // MARK: - Types
    enum AnimationPhase {
        case initial, phoneRaised, tshirtVisible, scanning, complete
    }
}

// MARK: - Preview
struct TShirtScannerView_Previews: PreviewProvider {
    static var previews: some View {
        FirstStepView()
    }
}
