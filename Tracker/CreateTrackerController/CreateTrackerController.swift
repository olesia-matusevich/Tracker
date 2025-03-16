//
//  CreateTrackerController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 10/03/2025.
//

import UIKit

class CreateTrackerController: UIViewController {
    
    // MARK: - Private properties
    
    private let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Новая привычка"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let limitLabel: UILabel = {
        var label = UILabel()
        label.text = "Органичение 38 символов"
        label.textColor = .red
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        return label
    }()
    
    private var nameNewTracker: UITextField = {
        var textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .castomGrayBackground
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        var button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .red
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Отменить", for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapCancelButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var createButton: UIButton = {
        var button = UIButton(type: .system)
        button.backgroundColor = .castomGray
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.castomGray.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Создать", for: .normal)
        button.isEnabled = false
        button.addTarget(
            self,
            action: #selector(didTapCreateButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let tableView = UITableView()
    private var options = ["Категория"] // список строк для tableView
    
    private var needSchedule: Bool = false
    private var nameIsEmpty: Bool = true
    
    private var selectedCategory: String = "Важное"
    private var selectedemoji: String = "😀"
    private var selectedColor: UIColor = .castomPurple
    private var selectedDays: [String] = []
    
    private var tableViewTopConstraint: NSLayoutConstraint?
    weak var createTrackerDelegate: CreateTrackerProtocol?
    
    // MARK: - Overrides methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupСonstraints()
        setupTableView()
        view.backgroundColor = .white
        nameNewTracker.delegate = self
        checkFilling()
    }
    
    init(needSchedule: Bool) {
        super.init(nibName: nil, bundle: nil)
        if needSchedule {
            options.append("Расписание")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - @objc methods
    
    @objc func didTapCancelButton() {
        createTrackerDelegate?.cancelCreateTracker()
    }
    
    @objc func didTapCreateButton() {
        let data = createTracker()
        createTrackerDelegate?.addTracker(for: data)
        createTrackerDelegate?.cancelCreateTracker()
    }
    
    @objc func didTapCategoryButton() {
        checkFilling()
    }
    
    // MARK: - Private methods
    
    private func setupTableView() {
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
    }
    
    private func checkFilling() {
        var fillingIsCorrect = false
        let nameIsFilled = !(nameNewTracker.text?.isEmpty ?? true)
        let categoryIsFilled = selectedCategory != ""
        let scheduleIsFilled = selectedDays.count > 0
        
        if needSchedule {
            fillingIsCorrect = !nameIsEmpty && nameIsFilled && categoryIsFilled && scheduleIsFilled
        } else {
            fillingIsCorrect = !nameIsEmpty && nameIsFilled && categoryIsFilled
        }
        if fillingIsCorrect {
            createButton.isEnabled = true
        } else {
            createButton.isEnabled = false
        }
    }
    
    private func setupViews() {
        [titleLabel, nameNewTracker, stackView, tableView, limitLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            
            stackView.addArrangedSubview(cancelButton)
            stackView.addArrangedSubview(createButton)
        }
    }
    
    private func setupСonstraints(){
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            nameNewTracker.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            nameNewTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameNewTracker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameNewTracker.heightAnchor.constraint(equalToConstant: 75),
            
            limitLabel.topAnchor.constraint(equalTo: nameNewTracker.bottomAnchor, constant: 8),
            limitLabel.centerXAnchor.constraint(equalTo: nameNewTracker.centerXAnchor),
            
            //tableView.topAnchor.constraint(equalTo: nameNewTracker.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 200),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: nameNewTracker.bottomAnchor, constant: 24)
        tableViewTopConstraint?.isActive = true
        
    }
    
    // MARK: - Public methods
    
    func createTracker() -> TrackerCategory {
        var days = scheduleItems.allCases.compactMap {
            item in
            self.selectedDays.contains(item.rawValue) ? item : nil
        }
        
        let tracker = Tracker(name: nameNewTracker.text ?? "Новый трекер",
                              emoji: selectedemoji,
                              schedule: days,
                              color: selectedColor)
        let category = TrackerCategory(name: selectedCategory, trackers: [tracker])
        return category
    }
}

// MARK: - UITableViewDataSource

extension CreateTrackerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        
        cell.customLabel.text = options[indexPath.row]
        cell.customImageView.image = UIImage(named: "chevron" )
        cell.customImageView.tintColor = .systemGray
        
        if options[indexPath.row] == "Категория" {
            cell.detailLabel.text = selectedCategory
        } else {
            if selectedDays.count == 7 {
                cell.detailLabel.text = "Каждый день"
            } else {
                let shortDays = selectedDays.compactMap { shortDayNames[$0] }.joined(separator: ", ")
                cell.detailLabel.text = shortDays
            }
        }
        cell.backgroundColor = .castomGrayBackground
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        
        // закругление ячеек
        if options.count == 1 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == options.count - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreateTrackerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if options[indexPath.row] == "Расписание" {
            let scheduleVC = ScheduleViewController(data: selectedDays)
            scheduleVC.selectScheduleDelegate = self
            present(scheduleVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UITextFieldDelegate

extension CreateTrackerController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        let limitNotReached = newLength <= 38
        showLimitLabel(show: !limitNotReached)
        
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        nameIsEmpty = newText.isEmpty
        
        return limitNotReached
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        nameIsEmpty = true
        checkFilling()
        return true
    }
    
    func showLimitLabel(show: Bool) {
        if show {
            limitLabel.isHidden = false
            tableViewTopConstraint?.constant = 62
        } else {
            limitLabel.isHidden = true
            tableViewTopConstraint?.constant = 24
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - ScheduleViewControllerDelegate

extension CreateTrackerController: ScheduleViewControllerDelegate {
    func didSendSchedule(_ selectedDays: [String]) {
        self.selectedDays = selectedDays
        tableView.reloadData()
        checkFilling()
    }
}
