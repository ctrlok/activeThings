// Separate the logic for fetching to-dos into a struct
struct ToDo: Codable {
    let recordID: String
    let RecordName: String
}

struct Areas: Identifiable, Codable {
    let id: String
    let AreaName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "AreaID"
        case AreaName
    }
}
