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
    let image: UIImage // Change from @State to let, passed from CameraView
    let autoCreateCutout: Bool
    
    /// add a separate queue to prevent main thread blocking
    private let processingQueue = DispatchQueue(label: "ProcessingQueue")

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Creating cutout...")
            } else {
                // Display the original image and cutout (if created)
                CutoutView(image: .constant(image), cutout: $cutout)
            }

            if cutout != nil && autoCreateCutout {
                Button(action: {
                }) {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(UIColor.label))
                        .padding()
                }
            }
        }
        .padding()
        .onAppear {
            // If autoCreateCutout is true, start processing when the view loads
            if autoCreateCutout {
                createCutout()
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
    private func render(ciImage: CIImage) -> UIImage {
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
    
    func saveImageToDocuments(_ image: UIImage, fileName: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
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
            print("✅ Saved cutout to Core Data as binary data")
        } catch {
            print("❌ Failed to save image: \(error)")
        }
    }

}

//struct VisionView_Previews: PreviewProvider {
//    static var previews: some View {
//        VisionView(image: UIImage(systemName: "apple-test")!)
//    }
//}
