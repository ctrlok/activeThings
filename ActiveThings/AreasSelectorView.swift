import SwiftUI

struct AreaSelectorView: View {
    @EnvironmentObject var thingsManager: ThingsManager

    var body: some View {
        VStack {
            Text("Select Areas")
                .font(.headline)
            
            List(thingsManager.areas.sorted(by: {$0.areaName > $1.areaName})) { area in
                AreaSelectionRow(area: area, isSelected: isAreaSelected(area)) {
                    self.toggleAreaSelection(for: area)
                }
            }
        }
    }
    
    private func isAreaSelected(_ area: Area) -> Bool {
        thingsManager.selectedAreas.contains(area)
    }
    
    private func toggleAreaSelection(for area: Area) {
        if thingsManager.selectedAreas.contains(area) {
            thingsManager.selectedAreas.remove(area)
        } else {
            thingsManager.selectedAreas.insert(area)
        }
        thingsManager.saveSelectedAreas()
    }
    

}

struct AreaSelectionRow: View {
    let area: Area
    let isSelected: Bool
    let toggleSelection: () -> Void

    var body: some View {
        HStack {
            Text(area.areaName)
                .font(.body)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSelection()
        }
    }
}
