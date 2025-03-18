//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 04/03/2025.
//

import UIKit

final class StatisticsViewController: UIViewController {
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Статистика"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupСonstraints()
    }
    
    private func setupViews() {
        [titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupСonstraints(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
}
