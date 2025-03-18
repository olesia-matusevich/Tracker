//
//  CreateTrackerProtocol.swift
//  Tracker
//
//  Created by Alesia Matusevich on 15/03/2025.
//

import Foundation

protocol CreateTrackerProtocol: AnyObject {
    func cancelCreateTracker()
    func addTracker(for category: TrackerCategory)
}
