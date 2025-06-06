//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 04/03/2025.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statisticsTitle", comment: "")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .castomBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let container: UIView = {
        let container = UIView()
        container.isHidden = true
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private lazy var stubStackView: UIStackView = {
        let stubImageView = UIImageView(image: UIImage(named: "statisticsStub"))
        stubImageView.backgroundColor = .castomWhite
        let stubLabel = UILabel()
        stubLabel.text = NSLocalizedString("statistics_screen_stub", comment: "")
        stubLabel.textColor = UIColor.castomBlack
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        let stackView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = (numberOfCompletedTrackers > 0)
        
        return stackView
    }()
    
    private lazy var numberLabel: UILabel = {
        let numberLabel = UILabel()
        numberLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        numberLabel.textColor = .castomBlack
        numberLabel.text = String(numberOfCompletedTrackers)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return numberLabel
    }()
    
    private lazy var categoryTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        title.text = NSLocalizedString("trackersCompleted", comment: "")
        title.textColor = .castomBlack
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
     
    private struct StatisticsView {
        let number: Int = 0
        let title: String = ""
    }
    
    private lazy var statisticView: UIView = {
        let statisticView = UIView()
        
        statisticView.addSubview(numberLabel)
        statisticView.addSubview(categoryTitle)
        
        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: statisticView.topAnchor, constant: 12),
            numberLabel.leadingAnchor.constraint(equalTo: statisticView.leadingAnchor, constant: 12),
            categoryTitle.bottomAnchor.constraint(equalTo: statisticView.bottomAnchor, constant: -12),
            categoryTitle.leadingAnchor.constraint(equalTo: statisticView.leadingAnchor, constant: 12)
        ])
        
        statisticView.translatesAutoresizingMaskIntoConstraints = false
        statisticView.isHidden = (numberOfCompletedTrackers == 0)
        return statisticView
    }()

    private var numberOfCompletedTrackers: Int {
        return trackerRecordStore.numberOfCompletedTrackers()
    }
    
    private let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .castomBackground
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statisticView.addGradientBorder(colors: [.trackerColor01, .trackerColor09, .trackerColor03], width: 1, radius: 16)
    }
    
    // MARK: - Private Methods
   
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(container)
        view.addSubview(stubStackView)
        view.addSubview(statisticView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stubStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            statisticView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}

// MARK: - extension UIView 

extension UIView {
    func addGradientBorder(colors: [UIColor], width: CGFloat, radius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: width/2, dy: width/2),
            cornerRadius: radius
        ).cgPath
        shapeLayer.lineWidth = width
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineCap = .round
        
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
    }
}
