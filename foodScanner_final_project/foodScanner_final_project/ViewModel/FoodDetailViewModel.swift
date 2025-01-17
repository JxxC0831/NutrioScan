import Foundation
import SwiftUI

class FoodDetailViewModel: ObservableObject {
    @Published var food: FoodDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Consumer Key and Consumer Secret from FatSecret
    private let consumerKey = ""
    private let consumerSecret = ""

    func fetchFoodDetail(foodId: Int) {
        isLoading = true
        errorMessage = nil

        // API endpoint and HTTP method
        let baseURL = "https://platform.fatsecret.com/rest/server.api"
        let httpMethod = "GET"

        // OAuth and API parameters
        var parameters: [String: String] = [
            "method": "food.get.v2",
            "food_id": "\(foodId)",
            "format": "json",
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
            "oauth_version": "1.0"
        ]

        // Generate the signature and make the request
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

                // Print the raw JSON response for debugging
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response:\n\(rawResponse)")
                }

                // Parse the JSON response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let foodDict = json["food"] as? [String: Any] {

                        // Parse the food details
                        let foodName = foodDict["food_name"] as? String ?? "Unknown"
                        let foodDescription = foodDict["food_description"] as? String

                        // Parse servings
                        var servingsList: [String] = []
                        if let servings = foodDict["servings"] as? [String: Any],
                           let servingArray = servings["serving"] as? [[String: Any]] {

                            servingsList = servingArray.compactMap { servingDict in
                                if let servingDescription = servingDict["serving_description"] as? String,
                                   let calories = servingDict["calories"] as? String {
                                    return "\(servingDescription): \(calories) calories"
                                }
                                return nil
                            }
                        } else if let servingDict = foodDict["servings"] as? [String: Any],
                                  let serving = servingDict["serving"] as? [String: Any],
                                  let servingDescription = serving["serving_description"] as? String,
                                  let calories = serving["calories"] as? String {

                            servingsList.append("\(servingDescription): \(calories) calories")
                        }

                        self.food = FoodDetail(id: foodId, name: foodName, description: foodDescription, servings: servingsList)

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

// Define the FoodDetail model
struct FoodDetail: Identifiable {
    let id: Int
    let name: String
    let description: String?
    let servings: [String]?
}
