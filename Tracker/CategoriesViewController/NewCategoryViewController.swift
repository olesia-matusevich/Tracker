//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 11/05/2025.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    
    //MARK: - Private Properties
    
    private var viewModel: NewCategoryViewModel
    private var categoryTitle: String = ""
    
    private let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Новая категория"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor.castomGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.text = "Введите название категории"
        label.textColor = UIColor.castomGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 2
        textView.textContainer.heightTracksTextView = true
        textView.textContainer.lineBreakMode = .byTruncatingHead
        
        textView.delegate = self
        
        let paragrafStyle = NSMutableParagraphStyle()
        paragrafStyle.lineSpacing = 0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .paragraphStyle: paragrafStyle
        ]
        textView.typingAttributes = attributes
        
        return textView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "deleteButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(clearTextView), for: .touchUpInside)
        return button
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .castomGrayBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        view.addSubview(deleteButton)
        textView.addSubview(placeHolderLabel)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -41),
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: 2 * (UIFont.systemFont(ofSize: 17).lineHeight + 8)),
            deleteButton.heightAnchor.constraint(equalToConstant: 17),
            deleteButton.widthAnchor.constraint(equalToConstant: 17),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeHolderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            placeHolderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),
            placeHolderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    var updateCategories: Binding<String>?
    
    init(viewModel: NewCategoryViewModel = NewCategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private Methods
    
    private func bind() {
        viewModel.isButtonEnabled = { [weak self] state in
            self?.doneButton.isEnabled = state
            self?.doneButton.backgroundColor = state ? .castomBlack : .castomGray        }
        
        viewModel.categoryTitleIsChanged = { [weak self] title in
            self?.placeHolderLabel.isHidden = !title.isEmpty
            self?.deleteButton.isHidden = title.isEmpty
            self?.categoryTitle = title
        }
    }
    
    //MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        [titleLabel, doneButton, textFieldView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            textFieldView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldView.heightAnchor.constraint(equalToConstant: 75),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc private func clearTextView() {
        viewModel.clearCategoryTitle()
        textView.text = ""
    }
    
    @objc private func addNewCategory() {
        updateCategories?(categoryTitle)
        self.dismiss(animated: true)
    }
}

//MARK: - UITextViewDelegate

extension NewCategoryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.updateCategoryTitle(textView.text)
    }
}
