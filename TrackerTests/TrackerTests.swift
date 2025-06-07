//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Alesia Matusevich on 04/06/2025.
//

import Testing
import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewController() {
//        isRecording = true
        
        let vc = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        
        navigationController.view.frame = UIScreen.main.bounds
        
        vc.loadViewIfNeeded()
        
        assertSnapshot(
            matching: navigationController,
            as: .image
        )
    }
}

