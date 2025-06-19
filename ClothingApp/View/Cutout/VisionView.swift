//
//  VisionView.swift
//  CustomCameraApp
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
    let image: UIImage
    let autoCreateCutout: Bool
    
    @State private var selectedDetent: PresentationDetent = .height(200)
    
    @State private var isTagSheetPresented = false
    @State private var selectedTagIcon: String = "tshirt.fill"
    @State private var customTagLabel: String = ""
    @State private var isMainSheetPresented = true
    
    /// add a separate queue to prevent main thread blocking
    private let processingQueue = DispatchQueue(label: "ProcessingQueue")

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Top bar with back
                ZStack {
                    // Centered title
                    Text("Choose the tags")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button(action: {
                            // Handle back navigation
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding([.top, .horizontal], 16)


                // Image Preview Area
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemGray6))

                        if isLoading {
                            ProgressView("Creating cutout...")
                        } else {
                            CutoutView(image: .constant(image), cutout: $cutout)
                                .aspectRatio(contentMode: .fit)
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.55)
                    .clipped()

                    // Retry button under image
                    Button(action: {
                        didRunCutout = false
                        createCutout()
                    }) {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                            .font(.subheadline)
                    }
                }
                .padding()

                Spacer()
            }
            .sheet(isPresented: $isMainSheetPresented) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 6) {
                            tagRow(pill: CustomPill(icon: "tshirt.fill", label: "Tops"), value: "T-shirt")
                            tagRow(pill: CustomPill(icon: "paintbrush.fill", label: "Color"), value: "●")
                            tagRow(pill: CustomPill(icon: "thermometer.variable", label: "Weather"), value: "Sunny")
                            tagRow(pill: CustomPill(icon: "dollarsign.circle.fill", label: "Price"), value: "30")

                            MatchingBanner()
                                .padding(.top, 8)
                                .padding(.horizontal, -16)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal)
                    }

                    // Save button pinned to bottom
                    Button(action: {
                        // Save logic
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    .padding([.horizontal, .bottom], 16)
                }
                .presentationDetents([.height(200), .large], selection: $selectedDetent)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: .height(200)))
                .presentationCornerRadius(24)
                
                .sheet(isPresented: $isTagSheetPresented) {
                    TagSelectorSheet(
                        isPresented: $isTagSheetPresented,
                        selectedIcon: $selectedTagIcon,
                        customLabel: $customTagLabel
                    )
                }
            }

        }
        .onAppear {
            if autoCreateCutout && !didRunCutout {
                didRunCutout = true
                createCutout()
            }
        }
    }
    
    func tagRow(pill: CustomPill, value: String) -> some View {
        HStack {
            pill
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .onTapGesture {
            if pill.icon == "tshirt.fill" {
                selectedTagIcon = pill.icon
                customTagLabel = value
                isTagSheetPresented = true
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

#Preview {
    VisionView(
        image: UIImage(named: "tshirt_gray") ?? UIImage(), // Replace with a real asset name
        autoCreateCutout: false
    )
}
