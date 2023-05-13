import SwiftUI

struct PreferencesView: View {
    @State private var thingsToken: String = UserDefaults.standard.string(forKey: "thingsToken") ?? ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Preferences")
                .font(.largeTitle)

            HStack {
                Text("Things Token:")
                TextField("Enter token", text: $thingsToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Spacer()
        }
        .padding()
        .frame(width: 400, height: 200)
        .onChange(of: thingsToken) { newValue in
            UserDefaults.standard.set(newValue, forKey: "thingsToken")
        }
    }
}
