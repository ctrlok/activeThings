// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var thingsManager: ThingsManager

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    createTaskText()
                    createActiveAreaText()
                }
                .padding(.top, 15)
                .padding(.leading, 20)
                createBackgroundGradient(using: geometry)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            thingsManager.loadActiveArea()
            thingsManager.loadData()
        }
    }

    
    @ViewBuilder
    private func createActiveAreaText() -> some View {
        let gradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0.92, green: 0.92, blue: 0.92).opacity(0.8)]), startPoint: .leading, endPoint: .trailing)

        if let activeArea = thingsManager.activeArea {
            GradientText(text: activeArea.areaName, gradient: gradient)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)

        } else {
            GradientText(text: "No active area selected", gradient: gradient)
        }
    }
    
    @ViewBuilder
    private func createBackgroundGradient(using geometry: GeometryProxy) -> some View {
        let gradientCenter = UnitPoint(
            x: (geometry.frame(in: .local).midX - 320) / geometry.size.width,
            y: (geometry.frame(in: .local).midY - 320) / geometry.size.height
        )
        
        let gradientColors = Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.0)])
        
        let radialGradient = RadialGradient(
            gradient: gradientColors,
            center: gradientCenter,
            startRadius: 0,
            endRadius: 550
        )
        
        Rectangle()
            .fill(radialGradient)
            .scaleEffect(x: 1, y: 0.2, anchor: .topLeading)
            .edgesIgnoringSafeArea(.all)
            .zIndex(-1)
    }
    
    @ViewBuilder
    private func createTaskText() -> some View {
        OptionClickableText(taskID: thingsManager.firstToDo.id, taskName: thingsManager.firstToDo.name)

    }
}
