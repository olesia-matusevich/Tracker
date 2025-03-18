//
//  TrackerCellDelegate.swift
//  Tracker
//
//  Created by Alesia Matusevich on 15/03/2025.
//

import Foundation

protocol TrackerCellDelegate: AnyObject {
    func trackerCompleated(id: UUID)
    func countRecordsByID(id: UUID) -> Int
    func checkDate() -> Bool
}
