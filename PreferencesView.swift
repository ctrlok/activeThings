import SwiftUI
import KeyboardShortcuts

struct PreferencesView: View {
    @EnvironmentObject var thingsManager: ThingsManager

    @State private var thingsToken: String = UserDefaults.standard.string(forKey: "thingsToken") ?? ""
    @State private var appPosition: AppPosition = AppPosition(rawValue: UserDefaults.standard.string(forKey: "appPosition") ?? "") ?? .topLeft

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Add the ProjectSelectorView here
            AreaSelectorView()
                .padding()
            
            HStack {
                Text("Select Active Area:")
                KeyboardShortcuts.Recorder(for: .selectActiveArea)
            }
            
            Picker("App Position:", selection: $appPosition) {
                ForEach(AppPosition.allCases, id: \.self) { position in
                    Text(position.rawValue.capitalized).tag(position)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            .onChange(of: appPosition) { newValue in
                UserDefaults.standard.set(newValue.rawValue, forKey: "appPosition")
                (NSApplication.shared.delegate as? AppDelegate)?.windows.forEach { ($0.window as? CustomWindow)?.windowPosition = newValue }
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
