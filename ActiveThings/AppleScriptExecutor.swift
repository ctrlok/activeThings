import Foundation

final class ExecuteAppleScript {
    let scriptName: String
    private(set) var status = ""
    private let scriptfileUrl: URL?
    
    init(scriptName: String) {
        self.scriptName = scriptName
        do {
            let destinationURL = try FileManager.default.url(
                for: .applicationScriptsDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            self.scriptfileUrl = destinationURL.appendingPathComponent(self.scriptName)
            self.status = "Linking of scriptfile successful!"
        } catch {
            self.status = error.localizedDescription
            self.scriptfileUrl = nil
        }
    }
    
    func execute(completion: @escaping (Result<String, Error>) -> Void) {
        guard let scriptfileUrl = scriptfileUrl else {
            completion(.failure(NSError(domain: "Script file URL is nil", code: -1, userInfo: nil)))
            return
        }
        
        do {
            let scriptTask = try NSUserAppleScriptTask(url: scriptfileUrl)
            scriptTask.execute(withAppleEvent: nil) { (result, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let result = result {
                    let scriptResult = result.stringValue ?? ""
                    completion(.success(scriptResult))
                }
            }
        } catch {
            self.status = error.localizedDescription
            completion(.failure(error))
        }
    }
}
