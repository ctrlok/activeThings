import SwiftUI
import Foundation
import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let selectActiveArea = Self("selectActiveArea")
}


class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindowController] = []
    private let windowSize = NSSize(width: 500, height: 500) // Adjust this to your liking

    var thingsManager = ThingsManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView().environmentObject(thingsManager)

        setupWindows(for: NSScreen.screens, contentView: contentView)
        setupKeyboardShortcut()
        setupMenuBar()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDisplayUpdate), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        
    }

    private func setupWindows<V: View>(for screens: [NSScreen], contentView: V) {
        // Close existing windows
        for windowController in windows {
            windowController.close()
        }
        
        // Clear existing windows
        windows.removeAll()

        for screen in screens {
            // Create the window and set the content view.
            let windowController = createWindow(for: screen, contentView: contentView)
            windowController.showWindow(nil)
            windows.append(windowController)
        }
    }

    private func createWindow<V: View>(for screen: NSScreen, contentView: V) -> NSWindowController {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
            styleMask: [.borderless], // borderless window
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.level = NSWindow.Level(rawValue: -1000)
        window.collectionBehavior = [.canJoinAllSpaces, .managed, .fullScreenAuxiliary]
        window.isOpaque = false
        window.backgroundColor = NSColor.clear

        let screenSize = screen.visibleFrame.size
        let desiredWindowSize = NSSize(width: windowSize.width, height: windowSize.height) // Rename the constant to avoid conflict
        let windowOrigin = NSPoint(x: screen.visibleFrame.origin.x, y: screenSize.height + screen.visibleFrame.origin.y - desiredWindowSize.height + 2)
        window.setFrame(NSRect(origin: windowOrigin, size: desiredWindowSize), display: true)

        let windowController = NSWindowController(window: window)
        return windowController
        
    }

    @objc private func handleDisplayUpdate() {
        let screens = NSScreen.screens
        let contentView = ContentView().environmentObject(thingsManager)

        // Update the windows for the current screens
        setupWindows(for: screens, contentView: contentView)
    }
    
    private func setupKeyboardShortcut() {
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

private extension NSScreen {
    var screenNumber: Int {
        return deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! Int
    }

    var isValid: Bool {
        var displayCount: UInt32 = 0
        var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(CGDisplayCount(displayCount)))
        CGGetOnlineDisplayList(displayCount, &onlineDisplays, &displayCount)
        return onlineDisplays.contains(displayID)
    }

    var displayID: CGDirectDisplayID {
        return deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
    }
}

