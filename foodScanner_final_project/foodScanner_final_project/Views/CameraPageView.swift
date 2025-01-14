import SwiftUI
import CoreML
import Vision
import UIKit

struct CameraPageView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var prediction: String = "No prediction yet"
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    // Reduced top padding to move everything up
                    Spacer()

                    // Image or Placeholder
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 4))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(gradient: Gradient(colors: [.green.opacity(0.3), .teal.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
                                .frame(height: 300)
                                .shadow(radius: 5)

                            VStack {
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    

                                Text("Select a food image")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            }
                        }
                    }

                    // Prediction Result
                    VStack(spacing: 8) {
                        Text("Food Recognition")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text(prediction)
                            .font(.title2)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.teal.opacity(0.8))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .foregroundColor(.white)
                    }

                    // Buttons with updated gradient colors
                    HStack(spacing: 15) {
                        ActionButton(title: "Take a Photo", colors: [Color.purple, Color.teal]) {
                            sourceType = .camera
                            isShowingImagePicker = true
                        }

                        ActionButton(title: "Choose from Library", colors: [Color.purple.opacity(0.7), Color.teal.opacity(0.7)]) {
                            sourceType = .photoLibrary
                            isShowingImagePicker = true
                        }
                    }

                    // Navigation Link
                    NavigationLink(destination: SearchFoodByNameView(initialSearchTerm: prediction)) {
                        Text("Search for Food Details")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(prediction != "No prediction yet" ? Color.purple : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .disabled(prediction == "No prediction yet")

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)  // Reduced padding to move everything up
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(image: $selectedImage, sourceType: sourceType)
                }
                .onChange(of: selectedImage) { newImage in
                    if let image = newImage {
                        classifyImage(image: image)
                    }
                }
                .navigationTitle("Food Scanner")
            }
        }
    }

    // Image Classification
    func classifyImage(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: SeeFood().model) else {
            prediction = "Failed to load model"
            return
        }

        let request = VNCoreMLRequest(model: model) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let firstResult = results.first {
                DispatchQueue.main.async {
                    self.prediction = firstResult.identifier.capitalized
                }
            }
        }

        guard let ciImage = CIImage(image: image) else {
            prediction = "Failed to create CIImage"
            return
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            prediction = "Analysis failed: \(error.localizedDescription)"
        }
    }
}


struct ActionButton: View {
    let title: String
    let colors: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(radius: 5)
        }
    }
}


struct BottomView: View {
    @State private var selectedTab: Tab = .camera

    enum Tab {
        case home, camera, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomePageView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(Tab.home)

            // Camera Tab
            NavigationView {
                CameraPageView()
            }
            .tabItem {
                Image(systemName: "camera.fill")
                Text("Camera")
            }
            .tag(Tab.camera)

            // Profile Tab
            NavigationView {
                ProfilePageView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(Tab.profile)
        }
        .accentColor(.blue) // Highlight color for tabs
    }
}


// Preview
#Preview {
    BottomView()
}
