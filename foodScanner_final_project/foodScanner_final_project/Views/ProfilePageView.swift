import SwiftUI
import PhotosUI

// ProfilePageView for displaying and editing user profile
struct ProfilePageView: View {
    @AppStorage("userName") private var userName: String = "Username"
    @State private var userProfileImage: UIImage? = UIImage(systemName: "person.circle.fill")
    @State private var isEditingName: Bool = false // State for editing the name
    @State private var newName: String = "" // Temporary variable for editing
    @State private var userEmail: String = "user@example.com" // Example email
    @State private var isEditingEmail: Bool = false // State for editing the email
    @State private var isImagePickerPresented: Bool = false // State for presenting image picker
    
    // For image picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedItemData: Data? = nil

    var body: some View {
        ScrollView {
            VStack {
                // Profile Image
                if let userProfileImage = userProfileImage {
                    Image(uiImage: userProfileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 4))
                        .shadow(radius: 10)
                        .padding(.top, 40)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 4))
                        .shadow(radius: 10)
                        .padding(.top, 40)
                }

                // Change Profile Picture Button
                Button(action: {
                    isImagePickerPresented.toggle() // Toggle image picker
                }) {
                    Text("Change Profile Picture")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding([.horizontal, .bottom])

                // User Name
                VStack {
                    if isEditingName {
                        TextField("Enter your name", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.horizontal, .top])
                            .onSubmit {
                                userName = newName // Save the new name
                                isEditingName = false
                            }
                    } else {
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom, 10)
                    }

                    // Edit Button
                    Button(action: {
                        if isEditingName {
                            userName = newName // Save new name
                        } else {
                            newName = userName // Prepopulate with the current name
                        }
                        isEditingName.toggle()
                    }) {
                        Text(isEditingName ? "Save" : "Edit Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding([.horizontal, .bottom])
                }
                
                // User Email
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.headline)
                        .padding(.top, 20)
                    if isEditingEmail {
                        TextField("Enter your email", text: $userEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.horizontal, .top])
                            .onSubmit {
                                isEditingEmail = false
                            }
                    } else {
                        Text(userEmail)
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                    }
                    
                    // Edit Email Button
                    Button(action: {
                        isEditingEmail.toggle()
                    }) {
                        Text(isEditingEmail ? "Save Email" : "Edit Email")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding([.horizontal, .bottom])
                }

                Spacer()
            }
            .padding(.horizontal)
            .background(Color(.systemGroupedBackground)) // Light background for profile page
            .cornerRadius(15)
        }
        .navigationTitle("Profile")
        .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedItem, matching: .images) // Photo Picker
        .onChange(of: selectedItem) { newItem in
            // Retrieve selected photo data
            Task {
                // Retrieve selected asset
                if let selectedItem,
                   let data = try? await selectedItem.loadTransferable(type: Data.self) {
                    self.selectedItemData = data
                    if let image = UIImage(data: data) {
                        self.userProfileImage = image
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Tab = .profile

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
    ContentView()
}
