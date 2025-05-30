//
//  TrackerCell.swift
//  Tracker
//
//  Created by Alesia Matusevich on 13/03/2025.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Private properties
    
    var trackerID: UUID?
    
    var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16) // Размер шрифта
        label.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3) // Полупрозрачный фон
        label.layer.cornerRadius = 12// Делаем круг
        label.layer.masksToBounds = true // Обрезаем по границам
        return label
    }()
    
    var nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    var daysCountLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 15
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let plusIcon = UIImage(systemName: "plus", withConfiguration: iconConfig)
        button.setImage(plusIcon, for: .normal)
        let checkmarkIcon = UIImage(systemName: "checkmark", withConfiguration: iconConfig)
        button.setImage(checkmarkIcon, for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.isSelected = false
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let mainContainerView = UIView()
    
    // MARK: - Public properties
    
    var containerView = UIView()
    static let reuseIdentifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
   
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - @objc mathods
    
    @objc private func completeButtonTapped(_ sender: UIButton) {
        if !(delegate?.checkDate() ?? false ) { return }
        sender.isSelected.toggle()
        guard let color = completeButton.backgroundColor else { return }
        if completeButton.isSelected {
            completeButton.backgroundColor = color.withAlphaComponent(0.3)
        } else {
            completeButton.backgroundColor = color.withAlphaComponent(1)
        }
        guard let id = trackerID else { return }
        delegate?.trackerCompleated(id: id)
        let dayAmount = delegate?.countRecordsByID(id: id) ?? 0
        updateDayCounterLabel(dayAmount: dayAmount)
    }
    
    // MARK: - Private mathods
    
    private func setupViews() {
        containerView.layer.cornerRadius = 10
        
        mainContainerView.addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(nameLabel)
        mainContainerView.addSubview(daysCountLabel)
        mainContainerView.addSubview(completeButton)
        
        contentView.addSubview(mainContainerView)
    }
    
    private func setupLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: 0),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            
            completeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            completeButton.widthAnchor.constraint(equalToConstant: 30),
            completeButton.heightAnchor.constraint(equalToConstant: 30),
            
            mainContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            mainContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            mainContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            
        ])
    }

    private func updateDayCounterLabel(dayAmount: Int) {
        daysCountLabel.text = daysString(amoumnt: dayAmount)
    }
    
    func daysString(amoumnt dayAmount: Int) -> String {
        let lastDigit = dayAmount % 10
        let lastTwoDigits = dayAmount % 100
        
        let word: String
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            word = "дней"
        } else if lastDigit == 1 {
            word = "день"
        } else if lastDigit >= 2 && lastDigit <= 4 {
            word = "дня"
        } else {
            word = "дней"
        }
        return "\(dayAmount) \(word)"
    }
}
