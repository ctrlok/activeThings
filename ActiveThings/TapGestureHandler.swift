import SwiftUI

struct TransparentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.clear)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}

struct GradientText: View {
    let text: String
    let gradient: LinearGradient

    var body: some View {
        ZStack {
            Text(text)
                .foregroundColor(.clear)
                .background(gradient)
                .mask(Text(text))
        }
    }
}


struct OptionClickableText: View {
    let taskID: String
    let taskName: String

    var body: some View {
        Button(action: handleClick) {
              GradientText(
                  text: taskName,
                  gradient: LinearGradient(gradient: Gradient(stops: [
                      Gradient.Stop(color: Color(red: 0.8, green: 0.8, blue: 0.8), location: 0),
                      Gradient.Stop(color: Color.white, location: 0.3),
                      Gradient.Stop(color: Color.white, location: 0.7),
                      Gradient.Stop(color: Color(red: 0.92, green: 0.92, blue: 0.92).opacity(1), location: 1)
                  ]), startPoint: .leading, endPoint: .trailing)
              )
                  .font(.system(size: 15, weight: .regular))
          }
          .buttonStyle(TransparentButtonStyle())
    }

    private func handleClick() {
        let optionKeyPressed = NSApp.currentEvent?.modifierFlags.contains(.option) ?? false

        guard let thingsToken = UserDefaults.standard.string(forKey: "thingsToken") else {
            return
        }

        var urlString = "things:///show?id=\(taskID)"
        if optionKeyPressed {
            urlString = "things:///update?id=\(taskID)&completed=true&auth-token=\(thingsToken)"
        }


        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        } else {
            print("Failed to create URL from string: \(urlString)")
        }
    }
}
