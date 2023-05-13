import SwiftUI
import Foundation





struct ContentView: View {
    @ObservedObject var thingsManager: ThingsManager

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(RadialGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.0)]),
                                         center: UnitPoint(x: (geometry.frame(in: .local).midX - 320) / geometry.size.width,
                                                           y: (geometry.frame(in: .local).midY - 320) / geometry.size.height),
                                         startRadius: 0, endRadius: 550))
                    .scaleEffect(x: 1, y: 0.2, anchor: .topLeading) // Adjust the y value to change the vertical scaling
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(-1) // Set the zIndex of the gradient to -1
                
                OptionClickableText(taskID: thingsManager.firstToDo.id, taskName: thingsManager.firstToDo.name)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}




