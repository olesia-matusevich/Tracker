//
//  OnboardingPage.swift
//  Tracker
//
//  Created by Alesia Matusevich on 30/04/2025.
//

import UIKit

final class OnboardingPage: UIViewController {
    
    private let screenText: String
    private let backgroundImage: UIImage
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(showTabBarController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = screenText
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(screenText: String, backgroundImage: UIImage) {
        self.screenText = screenText
        self.backgroundImage = backgroundImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        [backgroundImageView, okButton, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -160),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func showTabBarController() {
        UserDefaults.standard.set(true, forKey: "onboardingWasShown")
        let window = UIApplication.shared.windows.first
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        UIView.transition(with: window!, duration: 0.5,
                          options: .transitionCrossDissolve, animations: nil)
    }
}
