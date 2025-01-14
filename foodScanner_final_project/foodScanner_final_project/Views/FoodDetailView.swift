import SwiftUI

struct FoodDetailView: View {
    let foodId: Int
    @StateObject private var viewModel = FoodDetailViewModel()//get info from FoodDetailViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let food = viewModel.food {
                Text(food.name)
                    .font(.headline)
                    .padding()

                if let description = food.description {
                    Text(description)
                        .padding()
                }

                if let servings = food.servings {
                    List(servings, id: \.self) { serving in
                        Text(serving)
                    }
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .onAppear {
            viewModel.fetchFoodDetail(foodId: foodId)
        }
        .navigationTitle("Food Details")
    }
}

