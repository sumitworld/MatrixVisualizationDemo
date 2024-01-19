//
//  MatrixModel.swift
//  MatrixVisualizationDemo
//
//  Created by Vivek Parmar on 2024-01-19.
//

import Foundation

struct HourData: Codable {
    let hour: String
    let recordCount: Int

    enum CodingKeys: String, CodingKey {
        case hour
        case recordCount = "record_count"
    }
}

struct DayData: Codable {
    let day: String
    let hours: [HourData]
    var xAxisLabel: String = ""
    var yAxisLabel: String = ""

    enum CodingKeys: String, CodingKey {
        case day
        case hours
    }
}
