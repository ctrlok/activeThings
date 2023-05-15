import SwiftUI
import KeyboardShortcuts

struct PreferencesView: View {
    @EnvironmentObject var thingsManager: ThingsManager


    @State private var thingsToken: String = UserDefaults.standard.string(forKey: "thingsToken") ?? ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Add the ProjectSelectorView here
            AreaSelectorView()
                .padding()
            
            HStack {
                Text("Select Active Area:")
                KeyboardShortcuts.Recorder(for: .selectActiveArea)
            }
            
            Spacer()
            
            HStack {
                Text("Things Token:")
                TextField("Enter token", text: $thingsToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Spacer()
        }
        .padding()
        .frame(width: 400, height: 600)
        .onChange(of: thingsToken) { newValue in
            UserDefaults.standard.set(newValue, forKey: "thingsToken")
        }
    }
}
