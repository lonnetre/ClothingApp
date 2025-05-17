//
//  Created by yehor on 03.05.25.
//

import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

struct VisionView: View {
    @State private var image: UIImage = UIImage.appleTest
    @State private var cutout: UIImage?
    @State var isLoading: Bool = false
    
    /// add a separate queue to prevent main thread blocking
    private let processingQueue = DispatchQueue(label: "ProcessingQueue")

    var body: some View {
        VStack {
            CutoutView(image: $image, cutout: $cutout)
            
//            if let maskImage = maskUIImage {
//                Text("Mask Image")
//                Image(uiImage: maskImage)
//                    .resizable()
//                    .scaledToFit()
//            }

            Button("Create a cutout") {
                createCutout()
            }
            .clipShape(Capsule())
            .padding(.top)
            .backgroundStyle(Color(.systemGray))
        }
        .padding()
    }

    /// 1. generate mask image
    /// 2. apply it to the original image
    func createCutout() {
        guard let inputImage = CIImage(image: image) else {
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
            }
        }
    }

    /// returns mask image with foregorund objects
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
}

struct VisionView_Previews: PreviewProvider {
    static var previews: some View {
        VisionView()
    }
}
