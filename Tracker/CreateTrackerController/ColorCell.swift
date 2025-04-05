//
//  ColorCell.swift
//  Tracker
//
//  Created by Alesia Matusevich on 19/03/2025.
//

import UIKit

final class ColorCell: UICollectionViewCell {

    let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -9),
            colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -9),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
