import SwiftUI
import Foundation
import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let selectActiveArea = Self("selectActiveArea")
}


class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(ThingsManager.shared)

        
        for screen in NSScreen.screens {
            // Create the window and set the content view.
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
                styleMask: [.borderless], // borderless window
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("Main Window")
            window.contentView = NSHostingView(rootView: contentView)
            window.level = NSWindow.Level(rawValue: -1000) // Change this line to place the widget in the background
            window.collectionBehavior = [.canJoinAllSpaces, .managed, .fullScreenAuxiliary]
            window.isOpaque = false
            window.backgroundColor = NSColor.clear

            let screenSize = screen.visibleFrame.size // Use visibleFrame to exclude the menu bar
            let windowSize = NSSize(width: 500, height: 500) // Adjust this to your liking
            let windowOrigin = NSPoint(x: screen.visibleFrame.origin.x, y: screenSize.height + screen.visibleFrame.origin.y - windowSize.height + 2) // Top-left corner, right under the menu bar
            window.setFrame(NSRect(origin: windowOrigin, size: windowSize), display: true)

            window.makeKeyAndOrderFront(nil)
            windows.append(window)
        }
        KeyboardShortcuts.onKeyUp(for: .selectActiveArea) {
            // Cycle through selected areas
            let selectedAreas = ThingsManager.shared.selectedAreas
            if let currentActiveArea = ThingsManager.shared.activeArea {
                let currentIndex = selectedAreas.firstIndex(of: currentActiveArea) ?? selectedAreas.endIndex
                let nextIndex = selectedAreas.index(after: currentIndex) == selectedAreas.endIndex ? selectedAreas.startIndex : selectedAreas.index(after: currentIndex)
                ThingsManager.shared.activeArea = selectedAreas[nextIndex]
            } else if let firstSelectedArea = selectedAreas.first {
                ThingsManager.shared.activeArea = firstSelectedArea
            }
            ThingsManager.shared.saveActiveArea()
        }
    }
}


@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var thingsManager = ThingsManager.shared
    
    var body: some Scene {
        Settings {
            PreferencesView()
                .environmentObject(thingsManager)

        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
    
}
