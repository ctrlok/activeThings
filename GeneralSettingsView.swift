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
