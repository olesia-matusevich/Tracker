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
        trakcer.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "smallcircle.filled.circle.fill"), tag: 0)
        
        let statistics = StatisticsViewController()
        statistics.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)
        
        self.setViewControllers([trakcer, statistics], animated: true)
    }
}
