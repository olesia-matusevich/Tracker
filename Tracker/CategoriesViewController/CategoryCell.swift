//
//  CategoryCell.swift
//  Tracker
//
//  Created by Alesia Matusevich on 01/05/2025.
//

import UIKit

final class CategoryCell: UITableViewCell {
    
    static let identifier = "CategoryCell"
    
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
        hideSeparator(false)
    }
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .castomBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.castomGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupConstraints() {
        self.addSubview(titleLabel)
        self.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5) // Высота разделителя
        ])
    }
    
    func setup(with model: CategoryViewModel) {
        titleLabel.text = model.title
        if model.isSelected {
            self.accessoryType = .checkmark
        }
        else {
            self.accessoryType = .none
        }
    }
    
    func hideSeparator(_ hide: Bool) {
        separatorView.isHidden = hide
    }
}
