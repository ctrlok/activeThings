// Things.swift
// Contains the models for ToDo and Area objects

import Foundation

// Represents a to-do item
struct ToDo: Codable {
    let recordID: String
    let recordName: String
    let area: String
}

extension ToDo {
    enum CodingKeys: String, CodingKey {
        case recordID
        case recordName = "RecordName"
        case area = "areaName"
    }
}


// Represents an area
struct Area: Identifiable, Codable, Hashable {
    let id: String
    let areaName: String
}

extension Area {
    enum CodingKeys: String, CodingKey {
        case id = "AreaID"
        case areaName = "AreaName"
    }
}
