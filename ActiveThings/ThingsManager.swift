import SwiftUI
import Foundation

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
