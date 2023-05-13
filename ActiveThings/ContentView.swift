import SwiftUI
import Foundation

// Separate the logic for fetching to-dos into a struct
struct ToDo: Codable {
    let recordID: String
    let RecordName: String
}

class ThingsManager: ObservableObject {
    static let shared = ThingsManager()
    
    @Published var firstToDo: (name: String, id: String) = ("", "")

    private init() {
        startFetchingToDos()
    }
    
    private func startFetchingToDos() {
        fetchToDos { [weak self] result in
            self?.firstToDo = result
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.fetchToDos { result in
                self?.firstToDo = result
            }
        }
    }
    
    func fetchToDos(completion: @escaping ((String, String)) -> Void) {
        DispatchQueue.global().async {
            let executeAppleScript = ExecuteAppleScript()
            executeAppleScript.execute { (status, result) in
                DispatchQueue.main.async {
                    if status == "Execution of AppleScript successful!" {
                        if let jsonData = result.data(using: .utf8) {
                            let decoder = JSONDecoder()
                            do {
                                let todo = try decoder.decode(ToDo.self, from: jsonData)
                                // Pass both name and ID to the completion handler
                                completion((todo.RecordName, todo.recordID))
                            } catch {
                                print("Error: \(error.localizedDescription)") // Print the error details
                                completion(("Error: Unable to decode JSON", ""))
                            }
                        } else {
                            completion((result, ""))
                        }
                    } else {
                        completion(("Error: \(status)", ""))
                    }
                    
                }
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var thingsManager: ThingsManager

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
                
                OptionClickableText(taskID: thingsManager.firstToDo.id, taskName: thingsManager.firstToDo.name)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 0))
//                    .overlay(
//                        LinearGradient(gradient: Gradient(stops: [
//                            Gradient.Stop(color: Color(red: 0.98, green: 0.98, blue: 0.98), location: 0),
//                            Gradient.Stop(color: Color.white, location: 80 / geometry.size.width),
//                            Gradient.Stop(color: Color.white, location: 300 / geometry.size.width),
//                            Gradient.Stop(color: Color(red: 0.92, green: 0.92, blue: 0.92).opacity(1), location: 1)
//                        ]), startPoint: .leading, endPoint: .trailing)
//                    )
//                    .mask(Text(thingsManager.firstToDo.name).font(.system(size: 18, weight: .regular))
//                    )
            
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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



