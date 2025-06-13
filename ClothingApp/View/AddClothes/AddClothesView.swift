//
//  AddClothesView.swift
//  ClothingApp
//
//  Created by yehor on 28.04.25.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct AddClothesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var presentMe: Bool
    @State private var showNextButton = false
    @State private var showVisionView = false
    @State private var showCamera = false
    @State private var currentStep: Int = 1

    let checklist = [
        "You’re on a plain background",
        "Clothing is fully visible",
        "Good lighting = best results!"
    ]
    
    var stepTitle: String {
        switch currentStep {
        case 1: return "Scan the clothing"
        case 2: return "Check if the photo is right"
        default: return "Add the tags"
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    // Dismiss Button
                    HStack {
                        Spacer()
                        Button(action: {
                            presentMe = false
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color(.gray))
                                .accessibilityLabel("Close")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.top)
                    }
                    .padding(.horizontal)
                    
                    // Title
                    Text("Step \(currentStep)/3: \(stepTitle)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    // Scanner View
                    HStack {
                        // Left button
                        if showNextButton {
                            Button(action: {
                                withAnimation {
                                    currentStep -= 1
                                    showNextButton = false
                                }
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(currentStep == 1 ? Color(UIColor.clear) : Color(UIColor.systemGray))
                            }
                            .padding(.leading, 20)
                            .transition(.scale.combined(with: .opacity))
                            
                            Spacer()
                        } else {
                            Spacer()
                        }
                        
                        if currentStep == 1 {
                            FirstStepView(onComplete: {
                                showNextButton = true
                            })
                        } else if currentStep == 2 {
                            SecondStepView(onComplete: {
                                showNextButton = true
                            })
                        } else if currentStep == 3 {
                            ThirdStepView(onComplete: {
                                showNextButton = true
                            })
                        }
                        
                        // Right Button - appears when animation completes
                        if showNextButton {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    currentStep += 1
                                    showNextButton = false
                                }
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(currentStep == 3 ? Color(UIColor.clear) : Color(UIColor.systemGray))
                            }
                            .padding(.trailing, 20)
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            Spacer()
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Checklist
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Make sure:")
                            .font(.body)
                            .bold()
                        
                        ForEach(checklist, id: \.self) { item in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                                Text(item)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                    // Photo Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            showCamera = true
                        }) {
                            PhotoOptionButton(icon: "camera.fill", label: "Take a photo", width: geometry.size.width / 2.3)
                        }

                        Button(action: {
                            // Add photo picker logic here
                        }) {
                            PhotoOptionButton(icon: "photo.fill.on.rectangle.fill", label: "Use already\nexisting photo", width: geometry.size.width / 2.3)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
//                    .navigationDestination(isPresented: $showVisionView) {
//                        VisionView()
//                    }
                    .fullScreenCover(isPresented: $showCamera) {
                        CameraView()
                    }
                    .onChange(of: showCamera) { newValue in
                        print("showCamera is now: \(newValue)")
                    }
                }
            }
        }
    }
}

struct PhotoOptionButton: View {
    let icon: String
    let label: String
    let width: CGFloat

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(.label))
            Text(label)
                .font(.footnote)
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: width, height: 70)
        .background(Color(.systemGray5))
        .cornerRadius(20)
    }
}
