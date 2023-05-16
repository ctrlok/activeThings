// Things.swift
// Contains the models for ToDo and Area objects

import Foundation

// Represents a to-do item
struct ToDo: Codable {
    let recordID: String
    let recordName: String
    let area: String
    let status: String
}

extension ToDo {
    enum CodingKeys: String, CodingKey {
        case recordID
        case recordName = "RecordName"
        case area = "areaName"
        case status = "statusName"
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
