import SwiftUI

struct ContentView: View {
    @EnvironmentObject var thingsManager: ThingsManager

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ZStack {
                    VisualEffectView()
                    
                    LinearGradient(gradient: Gradient(colors: [.black.opacity(0.4), .black.opacity(0.2)]),
                                   startPoint: .top, endPoint: .bottom)
                }
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .shadow(radius: 5)
                VStack(alignment: .leading) {
                    createTaskText().padding(.bottom, 5)
                    createActiveAreaText()
                    createCompleted()
                }
                .padding(.top, 15)
                .padding(.leading, 15)
            }
            .padding(10)
            .frame(maxWidth: 300, maxHeight: 100)
        }
        .onAppear {
            thingsManager.loadActiveArea()
            thingsManager.loadData()
        }
    }
    
    private var activeAreaGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.92, green: 0.92, blue: 0.92).opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
    }
    
    
    @ViewBuilder
    private func createActiveAreaText() -> some View {
        if let activeArea = thingsManager.activeArea {
            GradientText(text: activeArea.areaName, gradient: activeAreaGradient)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)

        } else {
            GradientText(text: "No active area selected", gradient: activeAreaGradient)
        }
    }
    
    @ViewBuilder
    private func createCompleted() -> some View {
            GradientText(text: "\(ThingsManager.shared.completedToday) of \(ThingsManager.shared.totalToday) is done!", gradient: activeAreaGradient)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
    }
    
    @ViewBuilder
    private func createTaskText() -> some View {
        OptionClickableText(taskID: thingsManager.firstToDo.id, taskName: thingsManager.firstToDo.name)
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .fullScreenUI
    var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    var isEmphasized: Bool = true

    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.isEmphasized = isEmphasized
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: NSViewRepresentableContext<Self>) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.isEmphasized = isEmphasized
        nsView.state = .active
    }
}

