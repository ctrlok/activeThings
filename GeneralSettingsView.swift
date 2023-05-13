import SwiftUI
import AppKit

class MainMenu: NSMenu {
    override init(title: String) {
        super.init(title: title)
        setupMenuItems()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMenuItems() {
        items.removeAll() // Remove all existing menu items

        // Add your custom menu items here, for example:
        let helpMenuItem = NSMenuItem(title: "Help", action: #selector(helpAction), keyEquivalent: "")
        helpMenuItem.target = self
        addItem(helpMenuItem)
    }

    @objc private func helpAction() {
        // Implement your custom help action here
    }
}

class AppModel: ObservableObject {
    @Published var activeView: ActiveView = .main
    @Published var highlightThingsToken: Bool = false

    enum ActiveView {
        case main
        case preferences
    }
}



struct PreferencesView: View {
    @State private var thingsToken: String = UserDefaults.standard.string(forKey: "thingsToken") ?? ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Preferences")
                .font(.largeTitle)

            HStack {
                Text("Things Token:")
                TextField("Enter token", text: $thingsToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Spacer()
        }
        .padding()
        .frame(width: 400, height: 200)
        .onChange(of: thingsToken) { newValue in
            UserDefaults.standard.set(newValue, forKey: "thingsToken")
        }
    }
}
