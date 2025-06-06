//
//  TabBarController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 04/03/2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let trakcer = TrackersViewController()
        let titleTrackers = NSLocalizedString("trackersTitle", comment: "")
        trakcer.tabBarItem = UITabBarItem(title: titleTrackers, image: UIImage(systemName: "smallcircle.filled.circle.fill"), tag: 0)
        
        let statistics = StatisticsViewController()
        let titleStatistics = NSLocalizedString("statisticsTitle", comment: "")
        statistics.tabBarItem = UITabBarItem(title: titleStatistics, image: UIImage(systemName: "hare.fill"), tag: 1)
        
        self.setViewControllers([trakcer, statistics], animated: true)
        self.tabBar.backgroundColor = .castomBackground
    }
}
