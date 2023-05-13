import SwiftUI
import Foundation


// Separate the logic for fetching to-dos into a struct
struct ToDo: Codable {
    let recordID: String
    let RecordName: String
}

struct ThingsManager {
    static let shared = ThingsManager()
    
    private init() {}
    
    func fetchToDos(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            let executeAppleScript = ExecuteAppleScript()
            executeAppleScript.execute { (status, result) in
                print("Status: \(status)") // Print the status
                print("Result: \(result)") // Print the result
                
                DispatchQueue.main.async {
                    if status == "Execution of AppleScript successful!" {
                        if let jsonData = result.data(using: .utf8) {
                            let decoder = JSONDecoder()
                            do {
                                let todo = try decoder.decode(ToDo.self, from: jsonData)
                                completion("\(todo.recordID): \(todo.RecordName)")
                            } catch {
                                print("Error: \(error.localizedDescription)") // Print the error details
                                completion("Error: Unable to decode JSON")
                            }
                        } else {
                            completion(result)
                        }
                    } else {
                        completion("Error: \(status)")
                    }
                    
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var firstToDo: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.0)]),
                                         center: UnitPoint(x: (geometry.frame(in: .local).midX - 320) / geometry.size.width,
                                                           y: (geometry.frame(in: .local).midY - 320) / geometry.size.height),
                                         startRadius: 0, endRadius: 550))
                    .scaleEffect(x: 1, y: 0.2, anchor: .topLeading) // Adjust the y value to change the vertical scaling
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(-1) // Set the zIndex of the gradient to -1
                
                Text(firstToDo)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 25, leading: 40, bottom: 0, trailing: 0))
                    .overlay(
                        LinearGradient(gradient: Gradient(stops: [
                            Gradient.Stop(color: Color(red: 0.98, green: 0.98, blue: 0.98), location: 0),
                            Gradient.Stop(color: Color.white, location: 80 / geometry.size.width),
                            Gradient.Stop(color: Color.white, location: 300 / geometry.size.width),
                            Gradient.Stop(color: Color(red: 0.92, green: 0.92, blue: 0.92).opacity(1), location: 1)
                        ]), startPoint: .leading, endPoint: .trailing)
                    )
                    .mask(Text(firstToDo).font(.system(size: 18, weight: .regular))
                    )
            
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear(perform: startFetchingToDos)
        }
    }
    
    func startFetchingToDos() {
        fetchToDos()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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
    var windows: [NSWindow] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

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
    }
}
