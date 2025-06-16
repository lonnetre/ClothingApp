//
//  Created by yehor on 03.05.25.
//

import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

struct VisionView: View {
//    @State private var image: UIImage = UIImage.appleTest
    @State private var cutout: UIImage?
    @State var isLoading: Bool = false
    @State private var didRunCutout = false
    let image: UIImage // Change from @State to let, passed from CameraView
    let autoCreateCutout: Bool
    
    /// add a separate queue to prevent main thread blocking
    private let processingQueue = DispatchQueue(label: "ProcessingQueue")

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if isLoading {
                    ProgressView("Creating cutout...")
                } else {
                    // Display the original image and cutout (if created)
                    CutoutView(image: .constant(image), cutout: $cutout)
                }
                
                if cutout != nil && autoCreateCutout {
                    HStack {
                        Button(action: {
                            // action
                        }) {
                            OptionButton(icon: "camera.fill", label: "Retry", width: geometry.size.width / 2.3)
                        }
                        Button(action: {
                            // action
                        }) {
                            OptionButton(icon: "house.fill", label: "Return to home page", width: geometry.size.width / 2.3)
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                if autoCreateCutout && !didRunCutout {
                    didRunCutout = true
                    createCutout()
                }
            }
        }
    }

    /// 1. generate mask image
    /// 2. apply it to the original image
    func createCutout() {
        guard let normalizedImage = normalizeImage(image),
              let inputImage = CIImage(image: normalizedImage) else {
            print("Failed to create CIImage")
            return
        }

        isLoading = true
        processingQueue.async {
            guard let maskImage = self.subjectMaskImage(from: inputImage) else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }

            let outputImage = self.apply(mask: maskImage, to: inputImage)
            let finalImage = self.render(ciImage: outputImage)

            DispatchQueue.main.async {
                self.cutout = finalImage
                self.isLoading = false

                saveImageToCoreData(finalImage, tags: ["cutout", "vision"], date: Date())
            }
        }
    }
    
    func normalizeImage(_ image: UIImage) -> UIImage? {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }

    /// returns mask image with foreground objects
    private func subjectMaskImage(from inputImage: CIImage) -> CIImage? {
        /// VNImageRequestHandler allows to perform image analysis requests pertaining to a single image
        let handler = VNImageRequestHandler(ciImage: inputImage)
        /// VNGenerateForegroundInstanceMaskRequest is a special request that generates an instance mask of noticable objects
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        /// perform the request
        do {
            try handler.perform([request])
        } catch {
            print(error)
            return nil
        }
        
        /// result of the requests is an array of VNInstanceMaskObservation objects (just need the first one for the one piece of clothes)
        guard let result = request.results?.first else {
            print("No observations found")
            return nil
        }
        
        /// generate the maskImage
        do {
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            return CIImage(cvPixelBuffer: maskPixelBuffer)
        } catch {
            print(error)
            return nil
        }
    }

    /// apply the mask on the original image
    private func apply(mask: CIImage, to image: CIImage) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        filter.backgroundImage = CIImage.empty()
        return filter.outputImage ?? image
    }

    /// render the image from CIImage -> UIImage after the manipulations
    func render(ciImage: CIImage) -> UIImage {
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // Ensure premultiplied alpha for transparent background
        let format = CIFormat.RGBA8
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent, format: format, colorSpace: colorSpace) else {
            return UIImage()
        }

        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
    
    func saveImageToDocuments(_ image: UIImage, fileName: String) -> URL? {
        guard let data = image.pngData() else { return nil }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func saveImageToCoreData(_ image: UIImage, tags: [String], date: Date) {
        let context = PersistenceController.shared.container.viewContext
        let newItem = CutoutImage(context: context)
        newItem.id = UUID()
        newItem.createdAt = date
        newItem.tags = tags.joined(separator: ",")
        newItem.image = image // Transformer will handle conversion

        do {
            try context.save()
            print("Saved cutout to Core Data as binary data")
        } catch {
            print("Failed to save image: \(error)")
        }
    }

}

