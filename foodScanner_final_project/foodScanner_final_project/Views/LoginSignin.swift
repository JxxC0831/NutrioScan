import SwiftUI

struct LoginSigninView: View {
    @State private var isRegistered = true // Set to true to show Login screen first
    
    var body: some View {
        NavigationView {
            if isRegistered {
                LoginView(isRegistered: $isRegistered)
            } else {
                SignUpView(isRegistered: $isRegistered)
            }
        }
    }
}

struct LoginView: View {
    @Binding var isRegistered: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var isLoginSuccessful = false
    @State private var errorMessage: String?
    
    // New state to control navigation
    @State private var isLoggedIn = false

    var body: some View {
        VStack {
            Text("NutrioScan Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            // Username Field
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 24)
            
            // Password Field
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 24)
            
            // Login Button
            Button(action: {
                login()
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 10)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            // Switch to Sign Up
            Button(action: {
                isRegistered = false
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
                    .padding(.top, 20)
            }
            
            // Navigation Link to HomePageView
            NavigationLink(destination: TabBarView(), isActive: $isLoggedIn) {
                EmptyView()
            }
        }
        .navigationTitle("Login")
        .background(Color.white) // Background color for the screen
    }
    
    func login() {
        if AuthManager.shared.authenticate(username: username, password: password) {
            isLoggedIn = true  // Navigate to HomePageView
            errorMessage = nil
            print("Login Successful")
        } else {
            errorMessage = "Invalid username or password."
        }
    }
}

struct SignUpView: View {
    @Binding var isRegistered: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("NutrioScan Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            // Username Field
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 24)
            
            // Password Field
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 24)
            
            // Confirm Password Field
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 24)
            
            // Sign Up Button
            Button(action: {
                signUp()
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 10)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            // Switch to Login
            Button(action: {
                isRegistered = true
            }) {
                Text("Already have an account? Login")
                    .foregroundColor(.blue)
                    .padding(.top, 20)
            }
        }
    }
    
    func signUp() {
        // Check if fields are empty
        if username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Check if passwords match
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }
        
        // Check if the username already exists
        if AuthManager.shared.isUsernameTaken(username: username) {
            errorMessage = "Username already taken."
            return
        }
        
        // Simulate saving the new user
        // For simplicity, you can save the new user data to your local storage (users.json)
        // or your backend here.
        let newUser = User(username: username, password: password)
        AuthManager.shared.addUser(newUser)
        
        // Set registration success and clear error message
        isRegistered = true
        errorMessage = nil
    }
}

// Preview
#Preview {
    LoginSigninView()
}
