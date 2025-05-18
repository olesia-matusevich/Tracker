//
//  CastomDayCell.swift
//  Tracker
//
//  Created by Alesia Matusevich on 11/03/2025.
//

import UIKit

final class CastomDayViewCell: UITableViewCell {
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    let toggleSwitch = UISwitch()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.castomGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        toggleSwitch.onTintColor = .castomBlue
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(toggleSwitch)
        contentView.addSubview(separatorView)
    }
    
    private func layoutViews() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func hideSeparator(_ hide: Bool) {
        separatorView.isHidden = hide
    }
}
