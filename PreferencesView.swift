import SwiftUI

override func windowDidLoad() {
    super.windowDidLoad()
    
    // Load MainMenu.xib
    if let mainMenu = NSNib(nibNamed: "MainMenu", bundle: nil) {
        mainMenu.instantiate(withOwner: self, topLevelObjects: nil)
        NSApp.mainMenu = self.menu
    } else {
        print("Failed to load MainMenu.xib")
    }
}
