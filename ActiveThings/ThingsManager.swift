import SwiftUI
import Foundation

class ThingsManager: ObservableObject {
    static let shared = ThingsManager()
    
    @Published var firstToDo: (name: String, id: String) = ("", "")

    public init() {
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
    
    func fetchAreas(completion: @escaping ([Areas]) -> Void) {
        DispatchQueue.global().async {
            let executeAppleScript = ExecuteAppleScript(scriptName: "fetchAreas.scpt")
            print("starting getting areas")
            executeAppleScript.execute { (status, result) in
                print("Resilt: \(result)")
                DispatchQueue.main.async {
                    if status == "Execution of AppleScript successful!" {

                        if let jsonData = result.data(using: .utf8) {
                        print("JSON Data: \(String(data: jsonData, encoding: .utf8) ?? "")")
                            let decoder = JSONDecoder()
                            do {
                                let areas = try decoder.decode([Areas].self, from: jsonData)
                                completion(areas)
                            } catch {
                                print("Error: \(error.localizedDescription)") // Print the error details
                                completion([])
                            }
                        } else {
                            completion([])
                        }
                    } else {
                        completion([])
                    }
                }
            }
        }
    }
    
    func fetchToDos(completion: @escaping ((String, String)) -> Void) {
        DispatchQueue.global().async {
            let executeAppleScript = ExecuteAppleScript(scriptName: "fetchToDos.scpt")
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
