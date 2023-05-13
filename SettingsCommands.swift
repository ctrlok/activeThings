import SwiftUI

struct SettingsCommands: Commands {
    @Binding var showSettings: Bool
    @Binding var thingsToken: String

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button("Settings") {
                showSettings = true
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}
