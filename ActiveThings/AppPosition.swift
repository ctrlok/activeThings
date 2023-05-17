import SwiftUI
import Foundation
import AppKit
import KeyboardShortcuts

enum AppPosition: String, CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

class CustomWindow: NSWindow {
    var windowPosition: AppPosition = .topLeft {
        didSet {
            updateWindowPosition()
        }
    }
    
    private func updateWindowPosition() {
        guard let screen = screen else { return }
        
        let windowWidth: CGFloat = 350
        let windowHeight: CGFloat = 200
        let padding: CGFloat = 15
        
        let x: CGFloat
        let y: CGFloat
        
        switch windowPosition {
        case .topLeft:
            x = padding
            y = screen.visibleFrame.height - windowHeight - padding
        case .topRight:
            x = screen.visibleFrame.width - windowWidth - padding
            y = screen.visibleFrame.height - windowHeight - padding
        case .bottomLeft:
            x = padding
            y = padding
        case .bottomRight:
            x = screen.visibleFrame.width - windowWidth - padding
            y = padding
        }
        
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}

