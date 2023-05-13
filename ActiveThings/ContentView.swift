import SwiftUI
import Foundation

// Separate the logic for fetching to-dos into a struct
struct ThingsManager {
    static let shared = ThingsManager()
    
    private init() {}
    
    func fetchToDos(completion: @escaping (String) -> Void) {
        let executeAppleScript = ExecuteAppleScript()
        executeAppleScript.execute { (status, result) in
            if status == "Execution of AppleScript successful!" {
                completion(result)
            } else {
                completion("Error: \(status)")
            }
        }
    }
}

struct ContentView: View {
    @State private var firstToDo: String = ""
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.0)]), center: .topLeading, startRadius: 0, endRadius: 150)
                .edgesIgnoringSafeArea(.all)
            
            
            Text(firstToDo)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: startFetchingToDos)
    }
    
    func startFetchingToDos() {
        fetchToDos()
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            fetchToDos()
        }
    }
    
    func fetchToDos() {
        ThingsManager.shared.fetchToDos { result in
            firstToDo = result
        }
    }
}

class ExecuteAppleScript {
    var status = ""
    private let scriptfileUrl: URL?

    init() {
        do {
            let destinationURL = try FileManager().url(
                for: FileManager.SearchPathDirectory.applicationScriptsDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask,
                appropriateFor: nil,
                create: true)
            self.scriptfileUrl = destinationURL.appendingPathComponent("fetchToDos.scpt")
            self.status = "Linking of scriptfile successful!"
        } catch {
            self.status = error.localizedDescription
            self.scriptfileUrl = nil
        }
    }

    func execute(completion: @escaping (String, String) -> Void) {
        do {
            let scriptTask = try NSUserAppleScriptTask(url: self.scriptfileUrl!)
            scriptTask.execute(withAppleEvent: nil) { (result, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion("Error: \(error.localizedDescription)", "")
                } else if let result = result {
                    let scriptResult = result.stringValue ?? ""
                    completion("Execution of AppleScript successful!", scriptResult)
                }
            }
        } catch {
            self.status = error.localizedDescription
            completion("Error: \(error.localizedDescription)", "")
        }
    }
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.borderless], // borderless window
            backing: .buffered, defer: false)
        window?.center()
        window?.setFrameAutosaveName("Main Window")
        window?.contentView = NSHostingView(rootView: contentView)
        window?.level = .floating
        window?.collectionBehavior = [.canJoinAllSpaces, .managed, .fullScreenAuxiliary]
        window?.isOpaque = false
        window?.backgroundColor = NSColor.clear

        let screenSize = window?.screen?.frame.size ?? NSSize(width: 800, height: 600)
        let windowSize = NSSize(width: 200, height: 100) // Adjust this to your liking
        let windowOrigin = NSPoint(x: 0, y: screenSize.height - windowSize.height) // Top-left corner
        window?.setFrame(NSRect(origin: windowOrigin, size: windowSize), display: true)

        window?.makeKeyAndOrderFront(nil)
    }
}
