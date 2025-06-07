//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 01/05/2025

import UIKit

final class CategoriesViewController: UIViewController {
    
    //MARK: - Private Properties
    
    private var viewModel: CategoriesViewModelProtocol
    
    private var categoryTitle: String = ""
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Категория"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .castomGrayBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    
    private lazy var stubContainer: UIView = {
        let stubContainer = UIView()
        stubContainer.translatesAutoresizingMaskIntoConstraints = false
        stubContainer.addSubview(stubStackView)
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: stubContainer.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: stubContainer.centerYAnchor)
        ])
        return stubContainer
    }()
    
    private lazy var stubStackView: UIStackView = {
        let stubImageView = UIImageView(image: UIImage(named: "noTrackersImage"))
        let stubLabel = UILabel()
        let text = "Привычки и события можно\nобъединить по смыслу"
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let lineHeight: CGFloat = 18
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.castomBlack,
            .baselineOffset: (lineHeight - font.lineHeight)
        ]
        stubLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        stubLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .castomBlack
        
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var setupCategoryTitle: Binding<String>?
    
    init(viewModel: CategoriesViewModelProtocol = CategoriesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    //MARK: - Private Methods
    
    private func bind() {
        viewModel.visibleDataChanged = { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.updateUI()
        }
    }
    
    private func setupViews() {
        [titleLabel, addCategoryButton, tableView, stubContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            stubContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stubContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stubContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            stubContainer.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor)
        ])
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
    }
    
    private func updateUI() {
        let numberOfRows = viewModel.numberOfCategories()
        let state = numberOfRows > 0
        
        stubContainer.isHidden = state
        tableView.isHidden = !state
        
        if state {
            let tableHeight = min(tableView.rowHeight*CGFloat(numberOfRows), floor( stubContainer.frame.height/tableView.rowHeight)*tableView.rowHeight)
            tableViewHeightConstraint?.constant = tableHeight
        }
    }
    
    @objc private func addCategory() {
        let newCategoryController = NewCategoryViewController()
        newCategoryController.updateCategories = { [weak self] title in
            self?.addNewCategory(with: title)
        }
        present(newCategoryController, animated: true)
    }
    
    //MARK: - Public Methods
    
    func addNewCategory(with title: String) {
        viewModel.addRecord(with: title)
    }
}

//MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else {
            return
        }
        viewModel.selectCategory(at: indexPath.row)
        cell.setup(with: viewModel.category(at: indexPath.row))
        setupCategoryTitle?(viewModel.selectedCategoryTitle ?? "")
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

//MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell
        else {
            return UITableViewCell()
        }
        
        let cellViewModel = viewModel.category(at: indexPath.row)
        cell.setup(with: cellViewModel)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.hideSeparator(true)
        }
        return cell
    }
}
