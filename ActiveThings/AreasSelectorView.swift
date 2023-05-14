import SwiftUI

struct ProjectSelectorView: View {
    @ObservedObject var thingsManager: ThingsManager
    @State private var areas: [Areas] = []
    @State private var selectedAreas: Set<String> = Set<String>()
    
    var body: some View {
        VStack {
            Text("Select Areas")
                .font(.headline)
            
            List(areas) { area in
                HStack {
                    Text(area.AreaName)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { selectedAreas.contains(area.id) },
                        set: { isSelected in
                            if isSelected {
                                selectedAreas.insert(area.id)
                            } else {
                                selectedAreas.remove(area.id)
                            }
                            saveSelectedAreas()
                        }
                    )).toggleStyle(CheckboxToggleStyle())
                }
            }
        }
        .onAppear {
            ThingsManager().fetchAreas { fetchedAreas in
                areas = fetchedAreas
            }
            loadSelectedAreas()
        }
    }
    
    func saveSelectedAreas() {
        let selectedAreasArray = Array(selectedAreas)
        UserDefaults.standard.set(selectedAreasArray, forKey: "selectedAreas")
    }
    
    func loadSelectedAreas() {
        if let selectedAreasArray = UserDefaults.standard.array(forKey: "selectedAreas") as? [String] {
            selectedAreas = Set(selectedAreasArray)
        }
    }
}
