import Foundation

class AuthManager {
    static let shared = AuthManager()
    private var users: [User] = []
    private let usersFileURL: URL
    
    init() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        usersFileURL = documentDirectory.appendingPathComponent("users.json")
        
        // Load users if the file exists
        loadUsers()
    }
    
    // Load users from the file
    func loadUsers() {
        if let data = try? Data(contentsOf: usersFileURL) {
            do {
                let savedUsers = try JSONDecoder().decode([User].self, from: data)
                users = savedUsers
                print("Users loaded successfully")
            } catch {
                print("Failed to decode users: \(error)")
            }
        } else {
            print("No users file found, starting with an empty user list.")
        }
    }
    
    // Save users to the file
    func saveUsers() {
        do {
            let data = try JSONEncoder().encode(users)
            try data.write(to: usersFileURL)
            print("Users saved successfully")
        } catch {
            print("Failed to save users: \(error)")
        }
    }
    
    // Add a new user to the list and save to file
    func addUser(_ user: User) {
        // Check if the user already exists
        if !isUsernameTaken(username: user.username) {
            users.append(user)
            saveUsers()  // Save the updated users array to the file
        } else {
            print("Username is already taken.")
        }
    }
    
    // Authenticate a user by username and password
    func authenticate(username: String, password: String) -> Bool {
        return users.contains { $0.username == username && $0.password == password }
    }
    
    // Check if a username already exists
    func isUsernameTaken(username: String) -> Bool {
        return users.contains { $0.username == username }
    }
}

struct User: Codable {
    let username: String
    let password: String
}
