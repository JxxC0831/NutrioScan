import SwiftUI
import Foundation


class SearchFoodViewModel: ObservableObject {
    @Published var searchTerm: String = ""
    @Published var results: [FoodItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    //Consumer Key and Consumer Secret from FatSecret
    private let consumerKey = "1913e819073e4c3187bcd164640df2e0"
    private let consumerSecret = "07b19f21626f4d238e7ac81da32f5f17"


    func searchFood() {
        guard !searchTerm.isEmpty else {
            errorMessage = "Please enter a search term."
            return
        }

        isLoading = true
        errorMessage = nil
        results = []

        // API endpoint and HTTP method
        let baseURL = "https://platform.fatsecret.com/rest/server.api"
        let httpMethod = "GET"

        // OAuth and API parameters
        var parameters: [String: String] = [
            "method": "foods.search",
            "search_expression": searchTerm,
            "format": "json",
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
            "oauth_version": "1.0"
        ]

        // Generate the signature and make the request (see below)

        // Sort the parameters and create the parameter string
        let sortedParameters = parameters
            .map { ($0.percentEncoded(), $1.percentEncoded()) }
            .sorted { $0.0 < $1.0 }

        let parameterString = sortedParameters
            .map { "\($0)=\($1)" }
            .joined(separator: "&")

        // Create the signature base string
        let signatureBaseString = "\(httpMethod.uppercased())&\(baseURL.percentEncoded())&\(parameterString.percentEncoded())"

        // Create the signing key
        let signingKey = "\(consumerSecret.percentEncoded())&"

        // Generate the OAuth signature
        let signatureData = hmacSha1(key: signingKey, data: signatureBaseString)
        let signature = signatureData.base64EncodedString()

        // Add the signature to the parameters WITHOUT percent-encoding
        parameters["oauth_signature"] = signature

        // Build the final request URL
        let finalParameters = parameters
            .map { ($0.percentEncoded(), $1.percentEncoded()) }
            .sorted { $0.0 < $1.0 }

        let finalParameterString = finalParameters
            .map { "\($0)=\($1)" }
            .joined(separator: "&")

        let requestURLString = "\(baseURL)?\(finalParameterString)"
        guard let requestURL = URL(string: requestURLString) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid URL."
            }
            return
        }

        // Create the URL request
        var request = URLRequest(url: requestURL)
        request.httpMethod = httpMethod

        // Execute the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received."
                    return
                }

                // Parse the JSON response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let result = json["foods"] as? [String: Any],
                       let foodArray = result["food"] as? [[String: Any]] {

                        self.results = foodArray.compactMap { foodDict in
                            // Parse each food item
                            if let foodIdString = foodDict["food_id"] as? String,
                               let foodId = Int(foodIdString),
                               let foodName = foodDict["food_name"] as? String,
                               let brandName = foodDict["brand_name"] as? String? {

                                return FoodItem(id: foodId, name: foodName, brandName: brandName)
                            }
                            return nil
                        }
                    } else {
                        self.errorMessage = "Invalid response format."
                    }
                } catch {
                    self.errorMessage = "Failed to parse response."
                }
            }
        }

        task.resume()
    }
}

// Define the FoodItem model
struct FoodItem: Identifiable {
    let id: Int
    let name: String
    let brandName: String?
}

