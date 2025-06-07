//
//  FilterViewController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 02/06/2025.
//

import UIKit

// MARK: - FilterModes

enum FilterModes: String {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case notCompleted = "Не завершенные"
}

// MARK: - FilterDelegate

protocol FilterDelegate: AnyObject {
    func filterTracker(with mode: FilterModes, date: Date)
}

// MARK: - FilterViewController

final class FilterViewController: UIViewController {

    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .castomGrayBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .castomGray
        tableView.allowsMultipleSelection = false
        if let selectedIndex = filters.firstIndex(where: { $0.mode.rawValue == UserDefaults.standard.string(forKey: "filter")}) {
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return tableView
    }()
    
    private let navigationBar = UINavigationBar()
    
    // MARK: - Properties
    
    var filterSelected: (() -> Void)?
    
    private var filters: [FilterCellModel] = [
        FilterCellModel(mode: FilterModes.all, isSelected: false),
        FilterCellModel(mode: FilterModes.today, isSelected: false),
        FilterCellModel(mode: FilterModes.completed, isSelected: false),
        FilterCellModel(mode: FilterModes.notCompleted, isSelected: false)
    ]

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupConstraints()
        setupFilters()
    }
    
    // MARK: - Setup
    
    private func setupFilters() {
        guard let savedFilter = UserDefaults.standard.string(forKey: "filter") else { return }
        
        filters = filters.map { filter in
            var modifiedFilter = filter
            modifiedFilter.isSelected = (filter.mode.rawValue == savedFilter)
            return modifiedFilter
        }
    }
    
    private func setupConstraints() {
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let title = UINavigationItem(title: "Фильтры")
        navigationBar.setItems([title], animated: false)
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.castomBlack
        ]
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }
}

// MARK: - UITableViewDelegate

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FilterCell else {
            return
        }
        UserDefaults.standard.set(filters[indexPath.row].mode.rawValue, forKey: "filter")
        setupFilters()
        cell.setup(with: filters[indexPath.row])
        DispatchQueue.main.async {
            self.filterSelected?()
        }
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell
        else {
            return UITableViewCell()
        }
        setupFilters()
        let cellViewModel = filters[indexPath.row]
        cell.setup(with: cellViewModel)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        }
        return cell
    }
}

