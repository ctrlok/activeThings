import SwiftUI

struct PreferencesView: View {
    @ObservedObject var thingsManager: ThingsManager

    @State private var thingsToken: String = UserDefaults.standard.string(forKey: "thingsToken") ?? ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Add the ProjectSelectorView here
            ProjectSelectorView(thingsManager: thingsManager)
                .padding()
            
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
