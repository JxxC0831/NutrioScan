import SwiftUI

struct WelcomeScreen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Vibrant Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.teal, Color.purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    // Centered Logo Section
                    VStack(spacing: 8) {
                        Image("nutrioscan_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .shadow(color: .black.opacity(0.2), radius: 10)
                    }

                    // Icon Layout
                    HStack(spacing: 30) {
                        CircleView(imageName: "photo")
                        CircleView(imageName: "camera")
                        CircleView(imageName: "magnifyingglass")
                    }
                    .padding(.top, 20)

                    HStack(spacing: 30) {
                        CircleView(imageName: "fork.knife")
                        CircleView(imageName: "takeoutbag.and.cup.and.straw.fill")
                        CircleView(imageName: "star")
                    }

                    // Text Section
                    VStack(spacing: 5) {
                        Text("Click, Scan, and Enjoy!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Your health companion starts here.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    // Get Started Button
                    NavigationLink(destination: LoginSigninView()) { // Navigate to LoginSigninView
                        Text("Get Started")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.pink]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 40)
                    .navigationBarBackButtonHidden(true) // Ensures back button is hidden
                    Spacer()
                }
            }
        }
    }
}

// CircleView component for icons
struct CircleView: View {
    let imageName: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.25))
                .frame(width: 80, height: 80)
                .shadow(color: .black.opacity(0.15), radius: 5)

            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
        }
    }
}

// Preview
#Preview {
    WelcomeScreen()
}
