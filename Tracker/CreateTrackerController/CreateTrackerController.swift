//
//  CreateTrackerController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 10/03/2025.
//

import UIKit

final class CreateTrackerController: UIViewController {
    
    // MARK: - Private properties
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        if needSchedule {
            label.text = "Новая привычка"
        } else {
            label.text = "Новое нерегулярное событие"
        }
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let emojiLabel: UILabel = {
        var label = UILabel()
        label.text = "Emoji"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 19)
        return label
    }()
    
    private let colorLabel: UILabel = {
        var label = UILabel()
        label.text = "Цвет"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 19)
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
    
    private lazy var nameNewTracker: UITextField = {
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
    
    private let emojis: [String] = ["🙂","😻","🌺","🐶","❤️","😱",
                                    "😇","😡","🥶","🤔","🙌","🍔",
                                    "🥦","🏓","🥇","🎸","🏝","😪"]
   
    private let colors: [UIColor] = [.trackerColor01, .trackerColor02, .trackerColor03, .trackerColor04, .trackerColor05, .trackerColor06, .trackerColor07, .trackerColor08, .trackerColor09, .trackerColor10, .trackerColor11, .trackerColor12, .trackerColor13, .trackerColor14, .trackerColor15, .trackerColor16, .trackerColor17, .trackerColor18]
    
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    private lazy var emojisCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    
    private var needSchedule: Bool = false
    private var nameIsEmpty: Bool = true
    
    private var selectedCategory: String = "Важное"
    private var selectedEmoji: String = ""
    private var selectedColor: UIColor = .clear
//    private var selectedEmoji: String?
//    private var selectedColor: UIColor?
    private var selectedDays: [String] = []
    private let trackerStore = TrackerStore()
    
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
            self.needSchedule = true
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
        //saveTracker() //для сохранения в CoreData
        
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
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
    
    private func checkFilling() {
        var fillingIsCorrect = false
        let nameIsFilled = !(nameNewTracker.text?.isEmpty ?? true)
        let categoryIsFilled = selectedCategory != ""
        let scheduleIsFilled = selectedDays.count > 0
        let emojiIsFilled = selectedEmoji != ""
        let colorIsFilled = selectedColor != .clear
        
        
        if needSchedule {
            fillingIsCorrect = !nameIsEmpty && nameIsFilled && categoryIsFilled && emojiIsFilled && colorIsFilled && scheduleIsFilled
        } else {
            fillingIsCorrect = !nameIsEmpty && nameIsFilled && categoryIsFilled && emojiIsFilled && colorIsFilled
        }
        if fillingIsCorrect {
            createButton.isEnabled = true
        } else {
            createButton.isEnabled = false
        }
    }
    
    private func setupViews() {
        [titleLabel, nameNewTracker, stackView, tableView, limitLabel, emojisCollectionView, colorsCollectionView, emojiLabel, colorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            
            stackView.addArrangedSubview(cancelButton)
            stackView.addArrangedSubview(createButton)
        }
    }
    
    private func setupСonstraints(){
        
        let tableHeight = CGFloat(70 * options.count)
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            nameNewTracker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            nameNewTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameNewTracker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameNewTracker.heightAnchor.constraint(equalToConstant: 70),
            
            limitLabel.topAnchor.constraint(equalTo: nameNewTracker.bottomAnchor, constant: 8),
            limitLabel.centerXAnchor.constraint(equalTo: nameNewTracker.centerXAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
           tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            emojisCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
            emojisCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojisCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emojisCollectionView.heightAnchor.constraint(equalToConstant: 156),
            
            colorLabel.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            colorsCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
            colorsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            colorsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
            
        ])
        view.bringSubviewToFront(stackView)
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: nameNewTracker.bottomAnchor, constant: 24)
        tableViewTopConstraint?.isActive = true
    }
    
    // MARK: - Public methods
    
    func createTracker() -> TrackerCategory {
        let days = ScheduleItems.allCases.compactMap {
            item in
            self.selectedDays.contains(item.rawValue) ? item : nil
        }
        
        let tracker = Tracker(name: nameNewTracker.text ?? "Новый трекер",
                              emoji: selectedEmoji,
                              schedule: days,
                              color: selectedColor)
        let category = TrackerCategory(name: selectedCategory, trackers: [tracker])
        return category
    }
    
//    func saveTracker() {
//        let days = ScheduleItems.allCases.compactMap {
//            item in
//            self.selectedDays.contains(item.rawValue) ? item : nil
//        }
//        
//        let tracker = Tracker(name: nameNewTracker.text ?? "Новый трекер",
//                              emoji: selectedEmoji,
//                              schedule: days,
//                              color: selectedColor)
//        let category = selectedCategory
//        do {
//            try trackerStore.addNewTracker(tracker, category: category)
//        } catch {
//            print(error)
//        }
//    }
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
            cell.hideSeparator(true)
        } else if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == options.count - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.hideSeparator(true)
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
        
        checkFilling()
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkFilling()
        textField.resignFirstResponder()
        return true
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

// MARK: - UICollectionViewDataSource

extension CreateTrackerController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojisCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojisCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
            cell.emojiLabel.text = emojis[indexPath.item]
            if indexPath == selectedEmojiIndexPath {
                cell.backgroundView?.backgroundColor = .castomGraySelecledEmoji
                cell.backgroundView?.layer.cornerRadius = 16
            } else {
                cell.backgroundView?.backgroundColor = .clear
                cell.backgroundView?.layer.cornerRadius = 0
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.colorView.backgroundColor = colors[indexPath.item]
            if indexPath == selectedColorIndexPath {
                cell.layer.borderColor = colors[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.layer.borderWidth = 3
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 8
            } else {
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CreateTrackerController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollectionView {
            selectedEmojiIndexPath = indexPath
            selectedEmoji = emojis[indexPath.item]
        } else {
            selectedColorIndexPath = indexPath
            selectedColor = colors[indexPath.item]
        }
        collectionView.reloadData()
        checkFilling()
    }
}
