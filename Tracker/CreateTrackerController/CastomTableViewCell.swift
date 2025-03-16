//
//  CastomTableViewCell.swift
//  Tracker
//
//  Created by Alesia Matusevich on 11/03/2025.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    let customLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .castomGray
        return label
    }()
    
    let customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        contentView.addSubview(customImageView)
        
        stackView.addArrangedSubview(customLabel)
        stackView.addArrangedSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 24),
            customImageView.heightAnchor.constraint(equalToConstant: 24),
            
            stackView.trailingAnchor.constraint(equalTo: customImageView.leadingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

