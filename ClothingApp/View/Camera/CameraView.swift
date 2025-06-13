//
//  ContentView.swift
//  CustomCameraApp
//
//  Created by yehor on 03.06.25.
//

import SwiftUI

struct CameraView: View {
	
	@ObservedObject var viewModel = CameraViewModel()
    @State private var showVisionView = false
	
	@State private var isFocused = false
	@State private var isScaled = false
	@State private var focusLocation: CGPoint = .zero
	@State private var currentZoomFactor: CGFloat = 1.0
    @State private var isShowingImageViewer = false

	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Color.black.edgesIgnoringSafeArea(.all)
				
				VStack(spacing: 0) {
					Button(action: {
						viewModel.switchFlash()
					}, label: {
						Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
							.font(.system(size: 20, weight: .medium, design: .default))
					})
					.accentColor(viewModel.isFlashOn ? .yellow : .white)
					
					ZStack {
						CameraPreview(session: viewModel.session) { tapPoint in
							isFocused = true
							focusLocation = tapPoint
							viewModel.setFocus(point: tapPoint)
                            
                            // provide haptic feedback to enhance the user experience
							UIImpactFeedbackGenerator(style: .medium).impactOccurred()
						}
						.gesture(MagnificationGesture()
							.onChanged { value in
								self.currentZoomFactor += value - 1.0 // Calculate the zoom factor change
								self.currentZoomFactor = min(max(self.currentZoomFactor, 0.5), 10)
								self.viewModel.zoom(with: currentZoomFactor)
							})
//						.animation(.easeInOut, value: 0.5)
						
                        
                        // Note: Add this view below the end of CameraPreview view
                        // by wrapping both in the Zstack to show focus view above the preview
                        
                        // Show the FocusView when focus adjustments are in progress
                        if isFocused {
                            FocusView(position: $focusLocation)
                                .scaleEffect(isScaled ? 0.8 : 1)
                                .onAppear {
                                    // Add a springy animation effect for visual appeal.
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                                        self.isScaled = true
                                        // Return to the default state after 0.6 seconds for an elegant user experience.
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                            self.isFocused = false
                                            self.isScaled = false
                                        }
                                    }
                                }
						}
					}
					
					HStack {
                        Button(action: {
                            if viewModel.capturedImage != nil {
                                isShowingImageViewer = true
                            }
                        }) {
                            PhotoThumbnail(image: $viewModel.capturedImage)
                        }
						Spacer()
						CaptureButton { viewModel.captureImage() }
						Spacer()
						CameraSwitchButton { viewModel.switchCamera() }
					}
					.padding(20)
				}
			}
            .fullScreenCover(isPresented: $isShowingImageViewer) {
                if let image = viewModel.capturedImage {
                    PhotoPreviewView(capturedImage: image, onConfirm: {
                        showVisionView = true
                    }, onDeny: {
                        viewModel.capturedImage = nil
                        viewModel.isImageCaptured = false
                    })
                }
            }
            .fullScreenCover(isPresented: $showVisionView) {
                if let image = viewModel.capturedImage {
                    VisionView(image: image, autoCreateCutout: true)
                }
            }
            .onChange(of: viewModel.isImageCaptured) { isCaptured in
                print("isImageCaptured is now: \(isCaptured)")
                if isCaptured {
                    isShowingImageViewer = true
                    // Optionally remove this line:
                    // viewModel.isImageCaptured = false
                }
            }
            .onDisappear {
                print("CameraView disappeared")
            }
			.alert(isPresented: $viewModel.showAlertError) {
				Alert(title: Text(viewModel.alertError.title), message: Text(viewModel.alertError.message), dismissButton: .default(Text(viewModel.alertError.primaryButtonTitle), action: {
					viewModel.alertError.primaryAction?()
				}))
			}
			.alert(isPresented: $viewModel.showSettingAlert) {
				Alert(title: Text("Warning"), message: Text("Application doesn't have all permissions to use camera and microphone, please change privacy settings."), dismissButton: .default(Text("Go to settings"), action: {
					self.openSettings()
				}))
			}
			.onAppear {
				viewModel.setupBindings()
				viewModel.requestCameraPermission()
			}
		}
	}
	
    // use to open app's setting
	func openSettings() {
		let settingsUrl = URL(string: UIApplication.openSettingsURLString)
		if let url = settingsUrl {
			UIApplication.shared.open(url, options: [:])
		}
	}
}

struct PhotoThumbnail: View {
	@Binding var image: UIImage?
	
	var body: some View {
		Group {
            // if we have Image then we'll show image
			if let image {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 60, height: 60)
					.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            // else just show black view
			} else {
				Rectangle()
					.frame(width: 50, height: 50, alignment: .center)
					.foregroundColor(.black)
			}
		}
	}
}

struct CaptureButton: View {
	var action: () -> Void
	
	var body: some View {
		Button(action: action) {
			Circle()
				.foregroundColor(.white)
				.frame(width: 70, height: 70, alignment: .center)
				.overlay(
					Circle()
						.stroke(Color.black.opacity(0.8), lineWidth: 2)
						.frame(width: 59, height: 59, alignment: .center)
				)
		}
	}
}

struct CameraSwitchButton: View {
	var action: () -> Void
	
	var body: some View {
		Button(action: action) {
			Circle()
				.foregroundColor(Color.gray.opacity(0.2))
				.frame(width: 45, height: 45, alignment: .center)
				.overlay(
					Image(systemName: "camera.rotate.fill")
						.foregroundColor(.white))
		}
	}
}

struct FocusView: View {
	
	@Binding var position: CGPoint
	
	var body: some View {
		Circle()
			.frame(width: 70, height: 70)
			.foregroundColor(.clear)
			.border(Color.yellow, width: 1.5)
			.position(x: position.x, y: position.y)
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		
	}
}
