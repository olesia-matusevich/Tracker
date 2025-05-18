//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 11/03/2025.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSendSchedule(_ data: [String])
}

final class ScheduleViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Расписание"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var okButton: UIButton = {
        var button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        
        button.addTarget(
            self,
            action: #selector(didTapOkButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private let tableView = UITableView()
    private var selectedDays: [String] = []
    
    weak var selectScheduleDelegate: ScheduleViewControllerDelegate?
    
    // MARK: - Initializers
    
    init(data: [String]) {
        self.selectedDays = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides mathods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupViews()
        setupСonstraints()
        
        view.backgroundColor = .white
    }
    
    // MARK: - @objc mathods
    
    @objc func didTapOkButton() {
        selectScheduleDelegate?.didSendSchedule(selectedDays)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private mathods
    
    private func setupTableView() {
        
        tableView.register(CastomDayViewCell.self, forCellReuseIdentifier: "CustomDayCell")
        tableView.dataSource = self
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
        //tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupViews() {
        [titleLabel, okButton, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupСonstraints(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            okButton.heightAnchor.constraint(equalToConstant: 60),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -157),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomDayCell", for: indexPath) as? CastomDayViewCell
        else {return UITableViewCell()}
        
        cell.dayLabel.text = daysOfWeek[indexPath.row]
        cell.backgroundColor = .castomGrayBackground
        
        if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == daysOfWeek.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.hideSeparator(true)
        }
        cell.toggleSwitch.tag = indexPath.row
        cell.toggleSwitch.isOn = selectedDays.contains(daysOfWeek[indexPath.row])
        cell.toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        let day = daysOfWeek[sender.tag]
        if sender.isOn {
            selectedDays.append(day)
        } else {
            self.selectedDays.removeAll { $0 == day }
        }
    }
}
