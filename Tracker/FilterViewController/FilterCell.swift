//
//  FilterCell.swift
//  Tracker
//
//  Created by Alesia Matusevich on 02/06/2025.
//

import UIKit

struct FilterCellModel {
    let mode: FilterModes
    var isSelected: Bool
}

final class FilterCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .castomBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    static let identifier = "Filter cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func setupConstraints() {
        self.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])
    }
    
    func setup(with model: FilterCellModel) {
        titleLabel.text = model.mode.rawValue
        if model.isSelected {
            self.accessoryType = .checkmark
        }
        else {
            self.accessoryType = .none
        }
    }
}


