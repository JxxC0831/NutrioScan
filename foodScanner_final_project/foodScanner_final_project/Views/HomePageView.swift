import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = SearchFoodViewModel()
    @State private var selectedCategory: String? = nil
    @State private var searchHistory: [String] = []

    var body: some View {
        VStack(alignment: .leading) {
            header
            searchBar
            if !viewModel.results.isEmpty { searchResults }
            searchHistorySection
            askAIButton // The button to ask ChatBot for help
            Spacer()
        }
        .padding(.top)
        .navigationBarHidden(true)
    }

    private var header: some View {
        Text("Food at your fingertips")
            .font(.title)
            .fontWeight(.bold)
            .padding(.horizontal)
    }

    private var searchBar: some View {
        VStack {
            HStack {
                TextField("Search food...", text: $viewModel.searchTerm)
                    .padding(.leading, 16)
                    .frame(height: 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .onChange(of: viewModel.searchTerm) { _ in
                        // This will update results dynamically as the user types
                        viewModel.searchFood()
                    }

                // Search Button
                Button(action: {
                    performSearch()
                }) {
                    Text("Search")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        .padding(.top)
    }

    private func performSearch() {
        guard !viewModel.searchTerm.isEmpty else { return }
        // Update search history only when user presses "Search"
        if !searchHistory.contains(viewModel.searchTerm) {
            searchHistory.insert(viewModel.searchTerm, at: 0) // Add new search term to the history
        }
    }

    private var searchResults: some View {
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
        .frame(maxHeight: 300)
    }

    private var searchHistorySection: some View {
        VStack(alignment: .leading) {
            Text("Recent Searches")
                .font(.headline)
                .padding(.leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(searchHistory, id: \.self) { historyItem in
                        Button(action: {
                            viewModel.searchTerm = historyItem
                            performSearch()
                        }) {
                            Text(historyItem)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(15)
                                .foregroundColor(.black)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }

    // Ask AI Button
    private var askAIButton: some View {
        NavigationLink(destination: OpenAIServiceView()) {
            Text("Ask AI for more help")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.orange]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .padding(.horizontal)
    }
}


struct TabBarView: View {
    @State private var selectedTab: Tab = .home

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
        .accentColor(.blue)
    }
}

#Preview {
    TabBarView()
} 
