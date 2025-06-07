//
//  EmojiCell.swift
//  Tracker
//
//  Created by Alesia Matusevich on 19/03/2025.
//

import UIKit

final class EmojiCell: UICollectionViewCell {

    let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        backgroundView = UIView() // Добавляем backgroundView для выделения
    }
    
    func cellDidSelect() {
        contentView.backgroundColor = .castomGraySelecledEmoji
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
