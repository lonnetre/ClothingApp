//
//  CameraViewModel.swift
//  CustomCameraApp
//
//  Created by yehor on 03.06.25.
//

import SwiftUI
import Combine
import Photos
import AVFoundation

class CameraViewModel: ObservableObject {
    // Reference to the CameraManager.
	@ObservedObject var cameraManager = CameraManager()
    
    // Published properties to trigger UI updates.
	@Published var isFlashOn = false
	@Published var showAlertError = false
	@Published var showSettingAlert = false
	@Published var isPermissionGranted: Bool = false
	
	@Published var capturedImage: UIImage?
    @Published var isImageCaptured = false
	
	var alertError: AlertError!
    // Reference to the AVCaptureSession.
	var session: AVCaptureSession = .init()
    // Cancellable storage for Combine subscribers.
	private var cancelables = Set<AnyCancellable>()
	
    init() {
      // Initialize the session with the cameraManager's session.
      session = cameraManager.session
    }

    deinit {
      // Deinitializer to stop capturing when the ViewModel is deallocated.
      cameraManager.stopCapturing()
    }
	
    // Setup Combine bindings for handling publisher's emit values
	func setupBindings() {
		cameraManager.$shouldShowAlertView.sink { [weak self] value in
            // Update alertError and showAlertError based on cameraManager's state.
			self?.alertError = self?.cameraManager.alertError
			self?.showAlertError = value
		}
		.store(in: &cancelables)
		
		cameraManager.$capturedImage.sink { [weak self] image in
			self?.capturedImage = image
            // Signal that an image has been captured
            if image != nil {
                self?.isImageCaptured = true
            }
		}.store(in: &cancelables)
	}
	
	func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
            guard let self else { return }

            DispatchQueue.main.async {
                if isGranted {
                    self.isPermissionGranted = true
                    self.configureCamera()
                } else {
                    self.showSettingAlert = true
                }
            }
        }
	}
    
    func debugCameraStatus() {
        print("=== Camera Debug Info ===")
        print("Camera Manager Status: \(cameraManager.status)")
        print("Permission Granted: \(isPermissionGranted)")
        print("Session Running: \(session.isRunning)")
        print("Available Cameras:")
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        for device in discoverySession.devices {
            print("- \(device.localizedName) (Position: \(device.position.rawValue))")
        }
        print("========================")
    }
	
    // Configure the camera through the CameraManager to show a live camera preview.
    func configureCamera() {
        // Make sure session is properly configured
        if cameraManager.status == .unconfigured {
            cameraManager.configureCaptureSession()
            
            // Add a short delay and then check if we're still unconfigured
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                if self.cameraManager.status == .unconfigured {
                    // Try again if still not configured
                    print("Retrying camera configuration...")
                    self.cameraManager.configureCaptureSession()
                }
                self.debugCameraStatus()
            }
        }
    }
	
    // Check for camera device permission.
	func checkForDevicePermission() {
		let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
		
		DispatchQueue.main.async { [weak self] in
			if videoStatus == .authorized {
                // If Permission granted, configure the camera.
				self?.isPermissionGranted = true
			} else if videoStatus == .notDetermined {
                // In case the user has not been asked to grant access we request permission
				AVCaptureDevice.requestAccess(for: .video, completionHandler: { _ in })
			} else if videoStatus == .denied {
                // If Permission denied, show a setting alert.
				self?.isPermissionGranted = false
				self?.showSettingAlert = true
			}
		}
	}
	
	func switchCamera() {
		cameraManager.position = cameraManager.position == .back ? .front : .back
		cameraManager.switchCamera()
	}
	
	func switchFlash() {
		isFlashOn.toggle()
		cameraManager.toggleTorch(tourchIsOn: isFlashOn)
	}
	
	func zoom(with factor: CGFloat) {
		cameraManager.setZoomScale(factor: factor)
	}
	
    func setFocus(point: CGPoint) {
       // Delegate focus configuration to the CameraManager.
       cameraManager.setFocusOnTap(devicePoint: point)
    }
	
    func captureImage() {
        requestGalleryPermission()
        let permission = checkGalleryPermissionStatus()
        if permission.rawValue != 2 {
            cameraManager.captureImage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.isImageCaptured = true
                print("Image captured, isImageCaptured set to true")
            }
        }
    }
	
	func requestGalleryPermission() {
		PHPhotoLibrary.requestAuthorization { status in
			switch status {
			case .authorized:
				break
			case .denied:
				self.showSettingAlert = true
			default:
				break
			}
		}
	}
	
	func checkGalleryPermissionStatus() -> PHAuthorizationStatus {
		return PHPhotoLibrary.authorizationStatus()
	}
}
