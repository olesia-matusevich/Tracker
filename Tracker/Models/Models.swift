//
//  Models.swift
//  Tracker
//
//  Created by Alesia Matusevich on 07/03/2025.
//

import UIKit

struct Tracker: Identifiable {
    let id: UUID = UUID()
    let name: String
    let emoji: String
    let schedule: [ScheduleItems]?
    let color: UIColor
}

enum ScheduleItems: String, CaseIterable, Codable {
    case Monday = "Понедельник"
    case Tuesday = "Вторник"
    case Wednesday = "Среда"
    case Thursday = "Четверг"
    case Friday = "Пятница"
    case Saturday = "Суббота"
    case Sunday = "Воскресенье"
}

struct TrackerCategory {
    let name: String
    let trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
}

let daysOfWeek: [String] = [
    "Понедельник",
    "Вторник",
    "Среда",
    "Четверг",
    "Пятница",
    "Суббота",
    "Воскресенье"
]

// Словарь для сокращённых названий
let shortDayNames: [String: String] = [
    "Понедельник": "Пн",
    "Вторник": "Вт",
    "Среда": "Ср",
    "Четверг": "Чт",
    "Пятница": "Пт",
    "Суббота": "Сб",
    "Воскресенье": "Вс"
]
