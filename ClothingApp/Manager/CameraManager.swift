//
//  CameraManager.swift
//  CustomCameraApp
//
//  Created by yehor on 03.06.25.
//

import Photos
import SwiftUI
import AVFoundation

// Represents the camera's status
enum Status {
	case configured
	case unconfigured
	case unauthorized
	case failed
}

// this class conforms to ObservableObject to make it easier to use with future Combine code
class CameraManager: ObservableObject {
	
	@Published var capturedImage: UIImage? = nil
	@Published private var flashMode: AVCaptureDevice.FlashMode = .off
	
    // Observes changes in the camera's status
	@Published var status = Status.unconfigured
	@Published var shouldShowAlertView = false
	
    // AVCaptureSession manages the camera settings and data flow between capture inputs and outputs.
    // It can connect one or more inputs to one or more outputs
	let session = AVCaptureSession()
    // AVCapturePhotoOutput for capturing photos
	let photoOutput = AVCapturePhotoOutput()
    // AVCaptureDeviceInput for handling video input from the camera
    // Basically provides a bridge from the device to the AVCaptureSession
	var videoDeviceInput: AVCaptureDeviceInput?
	var position: AVCaptureDevice.Position = .back
	
	private var cameraDelegate: CameraDelegate?
	var alertError: AlertError = AlertError()
	
	// Communicate with the session and other session objects with this queue.
    // Serial queue to ensure thread safety when working with the camera
	private let sessionQueue = DispatchQueue(label: "com.demo.sessionQueue")
	
    // Method to configure the camera capture session
	func configureCaptureSession() {
		sessionQueue.async { [weak self] in
			guard let self, self.status == .unconfigured else { return }
            // Begin session configuration
			self.session.beginConfiguration()
            // Set session preset for high-quality photo capture
			self.session.sessionPreset = .photo
			
            // Add video input from the device's camera
            self.setupVideoInput()
               
            // Add the photo output configuration
            self.setupPhotoOutput()
			
            // Commit session configuration
            self.session.commitConfiguration()
            // Start capturing if everything is configured correctly
            self.startCapturing()
		}
	}
	
    // Method to set up video input from the camera
    private func setupVideoInput() {
        do {
            // Get the default wide-angle camera for video capture
            // AVCaptureDevice is a representation of the hardware device to use
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: position
            )

            guard let camera = discoverySession.devices.first else {
                print("CameraManager: No camera found for position \(position)")
                status = .unconfigured
                session.commitConfiguration()
                return
            }

            
            // Create an AVCaptureDeviceInput from the camera
            let videoInput = try AVCaptureDeviceInput(device: camera)
            
            // Add video input to the session if possible
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                videoDeviceInput = videoInput
                status = .configured
            } else {
                print("CameraManager: Couldn't add video device input to the session.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
        } catch {
            print("CameraManager: Couldn't create video device input: \(error)")
            status = .failed
            session.commitConfiguration()
            return
        }
    }

	
    // Method to configure the photo output settings
	private func setupPhotoOutput() {
		if session.canAddOutput(photoOutput) {
            // Add the photo output to the session
			session.addOutput(photoOutput)
            
            // Configure photo output settings
			// photoOutput.isHighResolutionCaptureEnabled = true
			photoOutput.maxPhotoQualityPrioritization = .quality // work for ios 15.6 and the older versions
			// photoOutput.maxPhotoDimensions = .init(width: 4032, height: 3024) // for ios 16.0*
            
            // Update the status to indicate successful configuration
			status = .configured
		} else {
			print("CameraManager: Could not add photo output to the session")
            // Set an error status and return
			status = .failed
			session.commitConfiguration()
			return
		}
	}
	
    // Method to start capturing
    private func startCapturing() {
        if status == .configured {
            // Start running the capture session
            self.session.startRunning()
        } else if status == .unconfigured || status == .unauthorized {
            DispatchQueue.main.async {
                // Handle errors related to unconfigured or unauthorized states
                self.alertError = AlertError(title: "Camera Error", message: "Camera configuration failed. Either your device camera is not available or its missing permissions", primaryButtonTitle: "ok", secondaryButtonTitle: nil, primaryAction: nil, secondaryAction: nil)
                self.shouldShowAlertView = true
                print("Capture session not started. Status: \(self.status)")
            }
        }
    }
	
    // Method to stop capturing
    func stopCapturing() {
        // Ensure thread safety using `sessionQueue`.
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            // Check if the capture session is currently running.
            if self.session.isRunning {
                // stops the capture session and any associated device inputs.
                self.session.stopRunning()
            }
        }
    }
	
    func toggleTorch(tourchIsOn: Bool) {
       // Access the default video capture device.
       guard let device = AVCaptureDevice.default(for: .video) else { return }
          // Check if the device has a torch (flashlight).
          if device.hasTorch {
            do {
                // Lock the device configuration for changes.
                try device.lockForConfiguration()

                // Set the flash mode based on the torchIsOn parameter.
                flashMode = tourchIsOn ? .on : .off

                // If torchIsOn is true, turn the torch on at full intensity.
                if tourchIsOn {
                   try device.setTorchModeOn(level: 1.0)
                } else {
                   // If torchIsOn is false, turn the torch off.
                   device.torchMode = .off
                }
                // Unlock the device configuration.
                device.unlockForConfiguration()
            } catch {
            // Handle any errors during configuration changes.
            print("Failed to set torch mode: \(error).")
          }
       } else {
          print("Torch not available for this device.")
       }
    }
	
    func setFocusOnTap(devicePoint: CGPoint) {
        guard let cameraDevice = self.videoDeviceInput?.device else { return }
        do {
            try cameraDevice.lockForConfiguration()

            // Check if auto-focus is supported and set the focus mode accordingly.
            if cameraDevice.isFocusModeSupported(.autoFocus) {
                cameraDevice.focusMode = .autoFocus
                cameraDevice.focusPointOfInterest = devicePoint
            }

            // Set the exposure point and mode for auto-exposure.
            cameraDevice.exposurePointOfInterest = devicePoint
            cameraDevice.exposureMode = .autoExpose

            // Enable monitoring for changes in the subject area.
            cameraDevice.isSubjectAreaChangeMonitoringEnabled = true

            cameraDevice.unlockForConfiguration()
        } catch {
            print("Failed to configure focus: \(error)")
        }
    }
	
	func setZoomScale(factor: CGFloat){
		guard let device = self.videoDeviceInput?.device else { return }
		do {
			try device.lockForConfiguration()
			device.videoZoomFactor = max(device.minAvailableVideoZoomFactor, max(factor, device.minAvailableVideoZoomFactor))
			device.unlockForConfiguration()
		} catch {
			print(error.localizedDescription)
		}
	}
	
	func switchCamera() {
		guard let videoDeviceInput else { return }
		
		// Remove the current video input
		session.removeInput(videoDeviceInput)
		
		// Add the new video input
		setupVideoInput()
	}
	
	func captureImage() {
		sessionQueue.async { [weak self] in
			guard let self else { return }
            
			
			var photoSettings = AVCapturePhotoSettings()
			
			// Capture HEIC photos when supported
			if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
				photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
			}
			
			// Sets the flash option for the capture
            if let device = self.videoDeviceInput?.device, device.isFlashAvailable {
				photoSettings.flashMode = self.flashMode
			}
			
			// photoSettings.isHighResolutionPhotoEnabled = true
			
			// Sets the preview thumbnail pixel format
			if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
				photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
			}
			photoSettings.photoQualityPrioritization = .quality
			
            if let videoConnection = photoOutput.connection(with: .video),
               videoConnection.isVideoRotationAngleSupported(90) {
                videoConnection.videoRotationAngle = 90 // 90 degrees corresponds to .portrait
            }
			
			cameraDelegate = CameraDelegate { [weak self] image in
				self?.capturedImage = image
			}
			
			if let cameraDelegate {
				self.photoOutput.capturePhoto(with: photoSettings, delegate: cameraDelegate)
			}
		}
	}
}

class CameraDelegate: NSObject, AVCapturePhotoCaptureDelegate {
	
	private let completion: (UIImage?) -> Void
	
	init(completion: @escaping (UIImage?) -> Void) {
		self.completion = completion
	}
	
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		if let error {
			print("CameraManager: Error while capturing photo: \(error)")
			completion(nil)
			return
		}
		
		if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
			saveImageToGallery(capturedImage)
			completion(capturedImage)
		} else {
			print("CameraManager: Image not fetched.")
		}
	}
	
	func saveImageToGallery(_ image: UIImage) {
		PHPhotoLibrary.shared().performChanges {
			PHAssetChangeRequest.creationRequestForAsset(from: image)
		} completionHandler: { success, error in
			if success {
				print("Image saved to gallery.")
			} else if let error {
				print("Error saving image to gallery: \(error)")
			}
		}
	}
}

public struct AlertError {
	public var title: String = ""
	public var message: String = ""
	public var primaryButtonTitle = "Accept"
	public var secondaryButtonTitle: String?
	public var primaryAction: (() -> ())?
	public var secondaryAction: (() -> ())?
	
	public init(title: String = "", message: String = "", primaryButtonTitle: String = "Accept", secondaryButtonTitle: String? = nil, primaryAction: (() -> ())? = nil, secondaryAction: (() -> ())? = nil) {
		self.title = title
		self.message = message
		self.primaryAction = primaryAction
		self.primaryButtonTitle = primaryButtonTitle
		self.secondaryAction = secondaryAction
	}
}
