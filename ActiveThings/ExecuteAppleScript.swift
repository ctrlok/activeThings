import SwiftUI
import Foundation


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
