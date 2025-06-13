//
//  PhotoPreviewView.swift
//  ClothingApp
//
//  Created by yehor on 03.06.25.
//

import SwiftUI

struct PhotoPreviewView: View {
    @Environment(\.presentationMode) var presentationMode
    let capturedImage: UIImage
    let onConfirm: () -> Void
    let onDeny: () -> Void
    
    // Adding explicit state to prevent auto-dismissal
    @State private var isVisible = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    
                    Spacer()
                    
                    HStack(spacing: 60) {
                        Button(action: {
                            print("Deny button tapped")
                            onDeny() // Call onDeny
                            // Explicitly dismiss the view when the user taps the button
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        Button(action: {
                            print("Confirm button tapped")
                            onConfirm()
                            // You can add functionality here to save the image,
                            // share it, or perform other actions
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            // Add this to ensure the view stays presented until explicitly dismissed
            .interactiveDismissDisabled()
            .onAppear {
                // Keep track that the view is visible
                isVisible = true
            }
        }
    }
}

//struct PhotoPreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview with a placeholder image
//        if let image = UIImage(systemName: "photo") {
//            PhotoPreviewView(capturedImage: image)
//        }
//    }
//}
