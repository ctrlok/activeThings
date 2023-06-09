import SwiftUI
import Foundation
import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let selectActiveArea = Self("selectActiveArea")
}

extension UserDefaults {
    @objc dynamic var appPosition: String {
        get { string(forKey: "appPosition") ?? "" }
        set { set(newValue, forKey: "appPosition") }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var windows: [NSWindowController] = []
    private let windowSize = NSSize(width: 300, height: 100) // Adjust this to your liking

    var thingsManager = ThingsManager.shared
    var statusBarMenu: NSMenu?
    var statusBar: NSStatusItem?
    weak var preferencesWindowController: NSWindowController?
    var appPositionObservation: NSKeyValueObservation?

    


    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView().environmentObject(thingsManager)

        setupWindows(for: NSScreen.screens, contentView: contentView)
        setupKeyboardShortcut()
        setupStatusBarMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDisplayUpdate), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        setupUserDefaultsObservation()
    }
    
    private func setupUserDefaultsObservation() {
        appPositionObservation = UserDefaults.standard.observe(\.appPosition, options: .new) { (_, _) in
            self.handleDisplayUpdate()
        }
    }

    deinit {
        appPositionObservation?.invalidate()
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

        // Calculate the desired position of the window
        let appPosition: AppPosition = AppPosition(rawValue: UserDefaults.standard.string(forKey: "appPosition") ?? "") ?? .topLeft
        let screenSize = screen.visibleFrame.size
        let screenOrigin = screen.visibleFrame.origin
        var windowOrigin: NSPoint

        switch appPosition {
        case .topLeft:
            windowOrigin = NSPoint(x: screenOrigin.x, y: screenOrigin.y + screenSize.height - windowSize.height)
        case .topRight:
            windowOrigin = NSPoint(x: screenOrigin.x + screenSize.width - windowSize.width, y: screenOrigin.y + screenSize.height - windowSize.height)
        case .bottomLeft:
            windowOrigin = NSPoint(x: screenOrigin.x, y: screenOrigin.y)
        case .bottomRight:
            windowOrigin = NSPoint(x: screenOrigin.x + screenSize.width - windowSize.width, y: screenOrigin.y)
        }

        window.setFrame(NSRect(origin: windowOrigin, size: windowSize), display: true)

        let windowController = NSWindowController(window: window)
        print("Screen visible frame: \(screen.visibleFrame)")
        print("Window frame: \(window.frame)")
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
    
    private func setupStatusBarMenu() {
        statusBarMenu = NSMenu()
        statusBarMenu?.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        statusBarMenu?.addItem(NSMenuItem.separator())
        statusBarMenu?.addItem(NSMenuItem(title: "Quit MyApp", action: #selector(quitApp), keyEquivalent: "q"))

        statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBar?.button?.image = NSImage(named: NSImage.Name("menubar2")) // Replace with your own image
        statusBar?.menu = statusBarMenu
    }

    @objc func showPreferences() {
        // Check if preferences window is already open
        if let windowController = self.preferencesWindowController {
            windowController.window?.makeKeyAndOrderFront(nil)
            return
        }

        let contentView = PreferencesView().environmentObject(self.thingsManager)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Preferences Window")
        window.contentView = NSHostingView(rootView: contentView)

        let windowController = NSWindowController(window: window)
        self.preferencesWindowController = windowController

        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
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

