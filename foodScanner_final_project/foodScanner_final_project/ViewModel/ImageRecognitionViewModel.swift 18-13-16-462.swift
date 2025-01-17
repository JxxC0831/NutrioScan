import SwiftUI
import PhotosUI

class ImageRecognitionViewModel: ObservableObject {
    @Published var recognizedFoods: [RecognizedFood] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let consumerKey = ""
    private let consumerSecret = ""
    
    func analyzeImage(_ image: UIImage) {
        isLoading = true
        errorMessage = nil
        recognizedFoods = []
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image"
            isLoading = false
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // API endpoint and HTTP method
        let baseURL = "https://platform.fatsecret.com/rest/image-recognition/v1"
        let httpMethod = "POST"
        
        // OAuth and API parameters
        var parameters: [String: String] = [
            "method": "POST",
            "format": "json",
            "image": base64Image,
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
            "oauth_version": "1.0"
        ]
        
        // Generate signature
        let sortedParameters = parameters
            .map { ($0.percentEncoded(), $1.percentEncoded()) }
            .sorted { $0.0 < $1.0 }
        
        let parameterString = sortedParameters
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
        
        let signatureBaseString = "\(httpMethod.uppercased())&\(baseURL.percentEncoded())&\(parameterString.percentEncoded())"
        let signingKey = "\(consumerSecret.percentEncoded())&"
        let signatureData = hmacSha1(key: signingKey, data: signatureBaseString)
        let signature = signatureData.base64EncodedString()
        
        parameters["oauth_signature"] = signature
        
        // Create request
        guard let url = URL(string: baseURL) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let finalParameters = parameters
            .map { "\($0.percentEncoded())=\($1.percentEncoded())" }
            .joined(separator: "&")
        
        request.httpBody = finalParameters.data(using: .utf8)
        
        // Execute request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let foods = json["foods"] as? [String: Any],
                       let foodArray = foods["food"] as? [[String: Any]] {
                        
                        self?.recognizedFoods = foodArray.compactMap { foodDict in
                            guard let foodIdString = foodDict["food_id"] as? String,
                                  let foodId = Int(foodIdString),
                                  let foodName = foodDict["food_name"] as? String,
                                  let confidenceString = foodDict["confidence"] as? String,
                                  let confidence = Double(confidenceString) else {
                                return nil
                            }
                            
                            return RecognizedFood(
                                id: foodId,
                                name: foodName,
                                confidence: confidence
                            )
                        }
                    } else {
                        self?.errorMessage = "Invalid response format"
                    }
                } catch {
                    self?.errorMessage = "Failed to parse response"
                }
            }
        }.resume()
    }
}

// RecognizedFood.swift
struct RecognizedFood: Identifiable {
    let id: Int
    let name: String
    let confidence: Double?
}

// ImagePicker.swift
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
