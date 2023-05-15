import SwiftUI
import Foundation

/// A manager class for handling areas and to-dos in the app.
class ThingsManager: ObservableObject {
    static let shared = ThingsManager()
    @Published var areas: Set<Area> = []
    @Published var activeArea: Area?
    @Published var selectedAreas: Set<Area> = []

    @Published var firstToDo: (name: String, id: String) = ("", "")
    
    private struct UserDefaultsKeys {
        static let selectedAreas = "selectedAreas"
        static let activeAreaID = "activeAreaID"
    }

    public init() {
        startFetchingToDos()
    }
    
    /// Starts fetching to-dos periodically.
    private func startFetchingToDos() {
        fetchToDos { [weak self] result in
            switch result {
            case .success(let todo):
                self?.firstToDo = todo
            case .failure(let error):
                self?.firstToDo = ("Error catching todo: \(error)", "")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.startFetchingToDos()
        }
    }
    
    /// Loads areas data.
    func loadData() {
        fetchAreas { result in
            switch result {
            case .success(let fetchedAreas):
                self.areas = fetchedAreas
                self.loadSelectedAreas()
            case .failure(let error):
                print("Error fetching areas: \(error)")
            }
        }
    }
    
    func isAreaSelected(_ area: Area) -> Bool {
        selectedAreas.contains(area)
    }
    
    func toggleAreaSelection(for area: Area) {
        if selectedAreas.contains(area) {
            selectedAreas.remove(area)
        } else {
            selectedAreas.insert(area)
        }
        saveSelectedAreas()
    }

    func saveSelectedAreas() {
        let selectedAreaIDsArray = self.selectedAreas.map { $0.id }
        UserDefaults.standard.set(selectedAreaIDsArray, forKey: UserDefaultsKeys.selectedAreas)
    }

    func loadSelectedAreas() {
        if let selectedAreaIDsArray = UserDefaults.standard.array(forKey: UserDefaultsKeys.selectedAreas) as? [String] {
            let selectedAreas = self.areas.filter { selectedAreaIDsArray.contains($0.id) }
            self.selectedAreas = Set(selectedAreas)
        }
    }

    func saveActiveArea() {
        if let activeArea = self.activeArea {
            UserDefaults.standard.set(activeArea.id, forKey: UserDefaultsKeys.activeAreaID)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.activeAreaID)
        }
    }

    func loadActiveArea() {
        if let activeAreaID = UserDefaults.standard.string(forKey: UserDefaultsKeys.activeAreaID) {
            self.activeArea = self.areas.first(where: { $0.id == activeAreaID })
        } else {
            self.activeArea = nil
        }
    }
    
    
    // Fetches to-dos data.
    func fetchToDos(completion: @escaping (Result<(String, String), Error>) -> Void) {
        loadData()
        loadActiveArea()
        DispatchQueue.global().async {
            let executeAppleScript = ExecuteAppleScript(scriptName: "fetchToDos.scpt")
            executeAppleScript.execute { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let scriptResult):
                        if let jsonData = scriptResult.data(using: .utf8) {
                            let result = decodeAndFilterToDos(jsonData: jsonData)
                            completion(result)
                        } else {
                            completion(.failure(NSError(domain: "ConversionError", code: -1, userInfo: nil)))
                        }
                    case .failure(let error):
                        completion(.failure(NSError(domain: "AppleScriptError", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])))
                    }
                }
            }
        }
    }

    private let specialArea = Area(id: "1", areaName: "No Areas")
    // Fetches areas data.
    func fetchAreas(completion: @escaping (Result<Set<Area>, Error>) -> Void) {
        DispatchQueue.global().async {
            let executeAppleScript = ExecuteAppleScript(scriptName: "fetchAreas.scpt")
            executeAppleScript.execute { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let scriptResult):
                        if let jsonData = scriptResult.data(using: .utf8) {
                            let decoder = JSONDecoder()
                            do {
                                var areas = try decoder.decode([Area].self, from: jsonData)
                                
                                // Add the special area as the first element
                                areas.append(self.specialArea)
                                
                                completion(.success(Set(areas)))
                            } catch {
                                completion(.failure(error))
                            }
                        } else {
                            completion(.failure(NSError(domain: "ConversionError", code: -1, userInfo: nil)))
                        }
                    case .failure(let error):
                        completion(.failure(NSError(domain: "AppleScriptError", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])))
                    }
                }
            }
        }
    }

}

/// Decodes and filters to-dos based on the active area.
private func decodeAndFilterToDos(jsonData: Data) -> Result<(String, String), Error> {
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
            return .success((firstTodo.recordName, firstTodo.recordID))
        } else {
            return .failure(NSError(domain: "NoFilteredTodos", code: -1, userInfo: nil))
        }
    } catch {
        return .failure(error)
    }
}
