import SwiftUI

struct AreaSelectorView: View {
    @EnvironmentObject var thingsManager: ThingsManager

    private var sortedAreas: [Area] {
        thingsManager.areas.sorted(by: { $0.areaName > $1.areaName })
    }

    var body: some View {
        VStack {
            Text("Select Areas")
                .font(.headline)
            
            List {
                ForEach(sortedAreas) { area in
                    AreaSelectionRow(area: area, isSelected: thingsManager.isAreaSelected(area)) {
                        thingsManager.toggleAreaSelection(for: area)
                    }
                }
            }
        }
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
