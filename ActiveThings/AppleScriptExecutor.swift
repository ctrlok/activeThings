import Foundation
import OSAKit

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
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Script file URL is nil", code: -1, userInfo: nil)))
            }
            return
        }
        
        do {
            let scriptSource = try String(contentsOf: scriptfileUrl)
            let script = OSAScript(source: scriptSource, language: OSALanguage(forName: "AppleScript"))
            
            var scriptError: NSDictionary?
            if let output = script.executeAndReturnError(&scriptError)?.stringValue {
                DispatchQueue.main.async {
                    completion(.success(output))
                }
            } else if let error = scriptError {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "AppleScriptError", code: -1, userInfo: error as? [String: Any])))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "UnknownError", code: -1, userInfo: nil)))
                }
            }
        } catch {
            self.status = error.localizedDescription
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}
