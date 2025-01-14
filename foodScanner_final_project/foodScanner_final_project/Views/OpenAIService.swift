import SwiftUI
import OpenAI

class ChatController: ObservableObject {
    //welcom page
    @Published var messages: [Message] = [
        .init(content: "Hello, welcome to your personal nutritionist. How can I help you today?", isUser: false)
    ]

    //OpenAI Key,
    let openAI = OpenAI(apiToken: "")

    //send message to chatbot
    func sendNewMessage(content: String) {
        let userMessage = Message(content: content, isUser: true)
        self.messages.append(userMessage)
        getBotReply()
    }

    //get reply from bot. set the prompt only for food 
    func getBotReply() {
        let prompt = """
        You are a specialized nutritionist assistant. When users provide ingredients:
        - Suggest 1-2 possible recipes using those ingredients.
        - For each recipe provide:
          * List of all ingredients with measurements.
          * Step-by-step cooking instructions.
          * Nutrition facts per serving (calories, protein, carbs, fats).
        If the user asks about anything unrelated to nutrition or food, politely refuse and guide them back to providing food items.
        """
        
        // Create system message
        guard let systemMessage = ChatQuery.ChatCompletionMessageParam(role: .system, content: prompt) else {
            return
        }
        
        // Map messages into ChatCompletionMessageParam
        let chatMessages = self.messages.compactMap { msg -> ChatQuery.ChatCompletionMessageParam? in
            return ChatQuery.ChatCompletionMessageParam(
                role: msg.isUser ? .user : .assistant,
                content: msg.content
            )
        }
        
        // Combine system message and chat history
        let queryMessages = [systemMessage] + chatMessages
        
        // Create ChatQuery
        let query = ChatQuery(
            messages: queryMessages,
            model: .gpt4, // Use gpt-4
            topP: 1.0
        )
        
        // Perform the API call
        openAI.chats(query: query) { [weak self] result in
            switch result {
            case .success(let success):
                guard let choice = success.choices.first,
                      let messageContent = choice.message.content,
                      case .string(let responseText) = messageContent else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.messages.append(Message(content: responseText, isUser: false))
                }
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

struct Message: Identifiable {
    var id = UUID()
    var content: String//message content
    var isUser: Bool//check if user
}


struct OpenAIServiceView: View {
    @StateObject var chatController: ChatController = .init()
    @State var string: String = ""
    var body: some View {
        VStack {
            // able to scroll
            ScrollView {
                ForEach(chatController.messages) {
                    message in
                    MessageView(message: message)
                        .padding(5)
                }
            }
            Divider()
            //ceat a send message box
            HStack {
                TextField("Message...", text: self.$string, axis: .vertical)
                    .padding(5)
                    .background(Color.gray.opacity(0.1))
                Button {
                    self.chatController.sendNewMessage(content: string)
                    string = ""
                } label: {
                    Image(systemName: "paperplane")//icon
                }
            }
            .padding()
        }
    }
}

//main view
struct MessageView: View {
    var message: Message
    var body: some View {
        Group {
            //check if the message is from user
            if message.isUser {
                HStack {
                    Spacer()
                    Text(message.content)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .clipShape(Capsule())
                }
            } else {
                HStack {
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
            }
        }
    }
}
#Preview {
    OpenAIServiceView()
}
