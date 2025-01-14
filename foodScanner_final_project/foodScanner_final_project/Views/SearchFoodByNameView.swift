import SwiftUI

struct SearchFoodByNameView: View {
    @StateObject private var viewModel = SearchFoodViewModel()
    var initialSearchTerm: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter food name", text: $viewModel.searchTerm)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onAppear {
                        // Automatically set and search for the initial term
                        if !initialSearchTerm.isEmpty {
                            viewModel.searchTerm = initialSearchTerm
                            viewModel.searchFood()
                        }
                    }
                
                Button(action: {
                    viewModel.searchFood()
                }) {
                    Text("Search")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding([.leading, .trailing])
                
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                List(viewModel.results) { foodItem in
                    NavigationLink(destination: FoodDetailView(foodId: foodItem.id)) {
                        VStack(alignment: .leading) {
                            Text(foodItem.name)
                                .font(.headline)
                            if let brandName = foodItem.brandName {
                                Text(brandName)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Search Food By Name")
        }
    }
}
