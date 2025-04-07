//
//  CastomTableViewCell.swift
//  Tracker
//
//  Created by Alesia Matusevich on 11/03/2025.
//

import UIKit

final class CustomTableViewCell: UITableViewCell {

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
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.castomGray // Цвет разделителя
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        contentView.addSubview(customImageView)
        contentView.addSubview(separatorView)
        
        stackView.addArrangedSubview(customLabel)
        stackView.addArrangedSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 24),
            customImageView.heightAnchor.constraint(equalToConstant: 24),
            
            stackView.trailingAnchor.constraint(equalTo: customImageView.leadingAnchor, constant: -8),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16), // Отступ слева
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), // Отступ справа
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5) // Высота разделителя
                  
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideSeparator(_ hide: Bool) {
        separatorView.isHidden = hide
    }
}

