// AppModelAndMenu.swift

import SwiftUI
import AppKit

final class MainMenu: NSMenu {
    init() {
        super.init(title: "")
        setupMenuItems()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMenuItems() {
        items.removeAll()
        
        let helpMenuItem = createMenuItem(title: "Help", action: #selector(helpAction))
        addItem(helpMenuItem)
    }

    private func createMenuItem(title: String, action: Selector) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
        menuItem.target = self
        return menuItem
    }

    @objc private func helpAction() {
        // Implement your custom help action here
    }
}

final class AppModel: ObservableObject {
    @Published var activeView: ActiveView = .main
    @Published var highlightThingsToken: Bool = false

    enum ActiveView {
        case main
        case preferences
    }
}
