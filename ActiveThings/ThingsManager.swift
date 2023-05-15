import SwiftUI
import Foundation

class ThingsManager: ObservableObject {
    static let shared = ThingsManager()
    @Published var areas: Set<Area> = []
    @Published var activeArea: Area?
    @Published var selectedAreas: Set<Area> = []

    
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
    
    func loadData() {
        fetchAreas { fetchedAreas in
            self.areas = fetchedAreas
            self.loadSelectedAreas()
        }
    }

    func saveSelectedAreas() {
        let selectedAreaIDsArray = self.selectedAreas.map { $0.id }
        UserDefaults.standard.set(selectedAreaIDsArray, forKey: "selectedAreas")
    }

    func loadSelectedAreas() {
        if let selectedAreaIDsArray = UserDefaults.standard.array(forKey: "selectedAreas") as? [String] {
            let selectedAreas = self.areas.filter { selectedAreaIDsArray.contains($0.id) }
            self.selectedAreas = Set(selectedAreas)
        }
    }
    
    func saveActiveArea() {
        if let activeArea = self.activeArea {
            UserDefaults.standard.set(activeArea.id, forKey: "activeAreaID")
        } else {
            UserDefaults.standard.removeObject(forKey: "activeAreaID")
        }
    }

    func loadActiveArea() {
        if let activeAreaID = UserDefaults.standard.string(forKey: "activeAreaID") {
            self.activeArea = self.areas.first(where: { $0.id == activeAreaID })
        } else {
            self.activeArea = nil
        }
    }
    
    func fetchAreas(completion: @escaping (Set<Area>) -> Void) {
        DispatchQueue.global().async {
            let executeAppleScript = ExecuteAppleScript(scriptName: "fetchAreas.scpt")
            print("starting getting areas")
            executeAppleScript.execute { (status, result) in
                print("Result: \(result)")
                DispatchQueue.main.async {
                    if status == "Execution of AppleScript successful!" {

                        if let jsonData = result.data(using: .utf8) {
                            print("JSON Data: \(String(data: jsonData, encoding: .utf8) ?? "")")
                            let decoder = JSONDecoder()
                            do {
                                var areas = try decoder.decode([Area].self, from: jsonData)
                                
                                // Add the special area as the first element
                                let specialArea = Area(id: "1", areaName: "No Areas")
                                areas.append(specialArea)
                                
                                completion(Set(areas))
                            } catch {
                                print("Error: \(error.localizedDescription)") // Print the error details
                                completion(Set())
                            }
                        } else {
                            completion(Set())
                        }
                    } else {
                        completion(Set())
                    }
                }
            }
        }
    }
    
    func fetchToDos(completion: @escaping ((String, String)) -> Void) {
        loadData()
        loadActiveArea()
        DispatchQueue.global().async {
            let executeAppleScript = ExecuteAppleScript(scriptName: "fetchToDos.scpt")
            executeAppleScript.execute { (status, result) in
                DispatchQueue.main.async {
                    if status == "Execution of AppleScript successful!" {
                        print("Result is: \(result)")
                        if let jsonData = result.data(using: .utf8) {
                            let decoder = JSONDecoder()
                            do {
                                let todos = try decoder.decode([ToDo].self, from: jsonData)
                                // Get the active area name
                                let activeAreaName = ThingsManager.shared.activeArea?.areaName
                                // Filter the todos based on the active area
                                let filteredTodos = todos.filter { $0.area == activeAreaName }
                                // Check if there are any filtered todos and select the first one
                                if let firstTodo = filteredTodos.first {
                                    // Pass both name and ID to the completion handler
                                    completion((firstTodo.recordName, firstTodo.recordID))
                                } else {
                                    print("No todos in the active area")
                                    completion(("No todos in the active area", ""))
                                }
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
