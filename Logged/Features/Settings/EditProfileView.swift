import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User

    // Emoji suggestions
    let emojis = ["🦁", "🐯", "🐻", "🦾", "🏋️", "🏃", "⚡️", "🔥", "💎", "🦍", "🦉", "🐺"]
    
    // Color suggestions (Hex)
    let colors = ["#4ADE80", "#FBBF24", "#EF4444", "#3B82F6", "#8B5CF6", "#EC4899", "#F472B6"]

    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var selectedEmoji: String = "🦁"
    @State private var selectedColor: String = "#4ADE80"

    var body: some View {
        NavigationStack {
            Form {
                Section("avatar") {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color(hex: selectedColor))
                                .frame(width: 80, height: 80)
                                .opacity(0.2)
                            
                            Text(selectedEmoji)
                                .font(.system(size: 40))
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojis, id: \.self) { emoji in
                                Button {
                                    selectedEmoji = emoji
                                    user.avatarEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.title2)
                                        .padding(8)
                                        .background(selectedEmoji == emoji ? Color.loggedAccent.opacity(0.2) : Color.clear)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { colorHex in
                                Button {
                                    selectedColor = colorHex
                                    user.avatarColor = colorHex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: colorHex))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == colorHex ? 2 : 0)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 8)
                    }
                }
                
                Section("details") {
                    TextField("name", text: $name)
                    
                    ZStack(alignment: .topLeading) {
                        if bio.isEmpty {
                            Text("bio")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $bio)
                            .frame(minHeight: 80)
                    }
                }
            }
            .font(.loggedBody)
            .navigationTitle("edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        save()
                    }
                }
            }
            .onAppear {
                name = user.name
                bio = user.bio ?? ""
                selectedEmoji = user.avatarEmoji ?? "🦁"
                selectedColor = user.avatarColor ?? "#4ADE80"
            }
        }
    }
    
    private func save() {
        user.name = name
        user.bio = bio
        user.avatarEmoji = selectedEmoji
        user.avatarColor = selectedColor
        dismiss()
    }
}

// Helper for Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
