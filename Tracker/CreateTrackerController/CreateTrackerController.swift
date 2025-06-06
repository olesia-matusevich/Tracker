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
        label.text = needSchedule ? "Новая привычка" : "Новое нерегулярное событие"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let emojiLabel: UILabel = {
        var label = UILabel()
        label.text = "Emoji"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorLabel: UILabel = {
        var label = UILabel()
        label.text = "Цвет"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        var title = "Создать"
        if isEditableMode {
            title = "Сохранить"
        }
        button.setTitle(title, for: .normal)
        button.isEnabled = false
        button.addTarget(
            self,
            action: #selector(didTapCreateButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var numberOfDaysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.text = numberOfDays
        label.isHidden = !isEditableMode
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentVieww: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private var needSchedule: Bool = false
    private var nameIsEmpty: Bool = true
    
    private var selectedCategory: String = ""
    private var selectedEmoji: String = ""
    private var selectedColor: UIColor = .clear
    private var selectedDays: [String] = []
    private var editableTracker: Tracker?
    private var numberOfDays: String?
    private var isEditableMode: Bool { editableTracker != nil}
    private let trackerStore = TrackerStore()
    private var selectedEmojiPath: IndexPath?
    private var selectedColorPath: IndexPath?
    
    var trackerEdited: ((Tracker, String) -> Void)?
    var trackerEditingCanceled: (() -> Void)?
    
    private var tableViewTopConstraint: NSLayoutConstraint?
    weak var createTrackerDelegate: CreateTrackerProtocol?
    
    private lazy var categoriesViewController: CategoriesViewController = {
        let controller = CategoriesViewController()
        return controller
    }()
    
    // MARK: - Overrides methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupСonstraints()
        setupTableView()
        view.backgroundColor = .white
        nameNewTracker.delegate = self
        
        if isEditableMode,
           let editableTracker = editableTracker,
           let numberOfDays = numberOfDays {
            setupEditableProperties(tracker: editableTracker, numberOfDays: numberOfDays)
        }
        checkFilling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        emojisCollectionView.layoutIfNeeded()
        let height = emojisCollectionView.contentSize.height
        emojisCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        colorsCollectionView.layoutIfNeeded()
        let heightcolorsCollectionView = colorsCollectionView.contentSize.height
        colorsCollectionView.heightAnchor.constraint(equalToConstant: heightcolorsCollectionView).isActive = true
        
        contentVieww.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: contentVieww.bounds.width, height: contentVieww.bounds.height + 60)
    }
    
    init(needSchedule: Bool, editableTracker: Tracker?, numberOfDays: String?) {
        super.init(nibName: nil, bundle: nil)
        
        self.editableTracker = editableTracker
        self.numberOfDays = numberOfDays
        
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
        
        if isEditableMode {
            guard let editableTracker = editableTracker
            else {
                print("[CreateTrackerController - didTapCreateButton()] - Не найден трекер для редактирования.")
                return
            }
            var days: [ScheduleItems] = []
            if !selectedDays.isEmpty {
                days = ScheduleItems.allCases.compactMap {
                    item in
                    self.selectedDays.contains(item.rawValue) ? item : nil
                }
            }
            
            let editedTracker = Tracker(id: editableTracker.id, name: nameNewTracker.text ?? "Отредактированный трекер",
                                        color: selectedColor, emoji: selectedEmoji,
                                        schedule: !selectedDays.isEmpty ? days : nil,
                                        isPinned: editableTracker.isPinned)
            
            self.trackerEdited?(editedTracker, selectedCategory)
        }
        else {
            let data = createTracker()
            createTrackerDelegate?.addTracker(for: data)
            createTrackerDelegate?.cancelCreateTracker()
        }
    }
    
    @objc func didTapCategoryButton() {
        checkFilling()
    }
    
    // MARK: - Private methods
    
    private func setupTableView() {
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
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
            createButton.backgroundColor = .castomBlack
            createButton.layer.borderColor = UIColor.castomBlack.cgColor
        } else {
            createButton.isEnabled = false
        }
    }
    
    private func setupViews() {
        [titleLabel, nameNewTracker, tableView, limitLabel, emojisCollectionView, colorsCollectionView, emojiLabel, colorLabel, stackView, numberOfDaysLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentVieww)
        contentVieww.addSubview(titleLabel)
        contentVieww.addSubview(nameNewTracker)
        contentVieww.addSubview(tableView)
        contentVieww.addSubview(limitLabel)
        contentVieww.addSubview(emojiLabel)
        contentVieww.addSubview(colorLabel)
        contentVieww.addSubview(emojisCollectionView)
        contentVieww.addSubview(colorsCollectionView)
        contentVieww.addSubview(stackView)
        contentVieww.addSubview(numberOfDaysLabel)
        
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
    }
    
    private func setupСonstraints(){
        
        let tableHeight = CGFloat(75 * options.count)
        
        if isEditableMode {
            NSLayoutConstraint.activate([
                
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                contentVieww.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentVieww.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentVieww.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentVieww.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentVieww.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: contentVieww.topAnchor, constant: 24),
                titleLabel.centerXAnchor.constraint(equalTo: contentVieww.centerXAnchor),
                titleLabel.heightAnchor.constraint(equalToConstant: 32),
                
                numberOfDaysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
                numberOfDaysLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                nameNewTracker.topAnchor.constraint(equalTo: numberOfDaysLabel.bottomAnchor, constant: 24),
                nameNewTracker.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 16),
                nameNewTracker.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -16),
                nameNewTracker.heightAnchor.constraint(equalToConstant: 75),
                
                limitLabel.topAnchor.constraint(equalTo: nameNewTracker.bottomAnchor, constant: 8),
                limitLabel.centerXAnchor.constraint(equalTo: nameNewTracker.centerXAnchor),
                
                tableView.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: tableHeight),
                
                emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 28),
                emojiLabel.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 28),
                emojiLabel.heightAnchor.constraint(equalToConstant: 18),
                
                emojisCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
                emojisCollectionView.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 16),
                emojisCollectionView.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -16),
                
                colorLabel.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor, constant: 16),
                colorLabel.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 28),
                colorLabel.heightAnchor.constraint(equalToConstant: 18),
                
                colorsCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
                colorsCollectionView.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 16),
                colorsCollectionView.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -16),
                
                stackView.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 12),
                stackView.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 20),
                stackView.centerXAnchor.constraint(equalTo: contentVieww.centerXAnchor),
                stackView.heightAnchor.constraint(equalToConstant: 60),
                stackView.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: contentVieww.bottomAnchor, constant: 0)
            ])
        } else {
            NSLayoutConstraint.activate([
                
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                contentVieww.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentVieww.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentVieww.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentVieww.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentVieww.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: contentVieww.topAnchor, constant: 24),
                titleLabel.centerXAnchor.constraint(equalTo: contentVieww.centerXAnchor),
                titleLabel.heightAnchor.constraint(equalToConstant: 32),
                
                nameNewTracker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
                nameNewTracker.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 16),
                nameNewTracker.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -16),
                nameNewTracker.heightAnchor.constraint(equalToConstant: 75),
                
                limitLabel.topAnchor.constraint(equalTo: nameNewTracker.bottomAnchor, constant: 8),
                limitLabel.centerXAnchor.constraint(equalTo: nameNewTracker.centerXAnchor),
                
                tableView.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: tableHeight),
                
                emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 28),
                emojiLabel.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 28),
                emojiLabel.heightAnchor.constraint(equalToConstant: 18),
                
                emojisCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
                emojisCollectionView.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 16),
                emojisCollectionView.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -16),
                
                colorLabel.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor, constant: 16),
                colorLabel.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 28),
                colorLabel.heightAnchor.constraint(equalToConstant: 18),
                
                colorsCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
                colorsCollectionView.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 16),
                colorsCollectionView.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -16),
                
                stackView.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 12),
                stackView.leadingAnchor.constraint(equalTo: contentVieww.leadingAnchor, constant: 20),
                stackView.centerXAnchor.constraint(equalTo: contentVieww.centerXAnchor),
                stackView.heightAnchor.constraint(equalToConstant: 60),
                stackView.trailingAnchor.constraint(equalTo: contentVieww.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: contentVieww.bottomAnchor, constant: 0)
            ])
        }
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: nameNewTracker.bottomAnchor, constant: 24)
        tableViewTopConstraint?.isActive = true
    }
    
    private func setupEditableProperties(tracker: Tracker, numberOfDays: String) {
        titleLabel.text = "Редактирование привычки"
        nameNewTracker.text = tracker.name
        nameIsEmpty = false
        
        let category = TrackerCategory(
            name: trackerStore.findCategoryTitle(by: tracker.id),
            trackers: [tracker]
        )
        setupCategoryTitle(category.name)
        if let schedule = tracker.schedule {
            for item in schedule {
                selectedDays.append(item.rawValue)
            }
        }
        selectedEmojiPath = IndexPath(row: emojis.firstIndex(where: { $0 == tracker.emoji}) ?? 0, section: 0)
        selectedColorPath = IndexPath(row: colors.firstIndex(where: { $0 == tracker.color}) ?? 0, section: 0)
        
        checkFilling()
    }
    
    private func createTracker() -> TrackerCategory {
        var days: [ScheduleItems] = []
        
        if !selectedDays.isEmpty {
            days = ScheduleItems.allCases.compactMap {
                item in
                self.selectedDays.contains(item.rawValue) ? item : nil
            }
        }
        let tracker = Tracker(name: nameNewTracker.text ?? "Новый трекер",
                              color: selectedColor, emoji: selectedEmoji,
                              schedule: !selectedDays.isEmpty ? days : nil,
                              isPinned: false)
        let category = TrackerCategory(name: selectedCategory, trackers: [tracker])
        return category
    }
    
    func setupCategoryTitle(_ title: String) {
        selectedCategory = title
        checkFilling()
    }
}

// MARK: - UITableViewDataSource

extension CreateTrackerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell
        else {
            return UITableViewCell()
        }
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
        if options[indexPath.row] == "Категория" {
            categoriesViewController.setupCategoryTitle = { [weak self] title in
                guard let self = self else { return }
                setupCategoryTitle(title)
                self.tableView.reloadData()
            }
            present(categoriesViewController, animated: true)
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
        switch collectionView {
        case emojisCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell
            else { return UICollectionViewCell() }
            cell.emojiLabel.text = emojis[indexPath.item]
            if indexPath == selectedEmojiIndexPath {
                cell.backgroundView?.backgroundColor = .castomGraySelecledEmoji
                cell.backgroundView?.layer.cornerRadius = 16
            } else if indexPath == selectedEmojiPath {
                cell.backgroundView?.backgroundColor = .castomGraySelecledEmoji
                cell.backgroundView?.layer.cornerRadius = 16
                selectedEmojiPath = nil
                selectedEmoji = emojis[indexPath.item]
            } else {
                cell.backgroundView?.backgroundColor = .clear
                cell.backgroundView?.layer.cornerRadius = 0
            }
            return cell
            
        case colorsCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell
            else { return UICollectionViewCell() }
            cell.colorView.backgroundColor = colors[indexPath.item]
            if indexPath == selectedColorIndexPath {
                cell.layer.borderColor = colors[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.layer.borderWidth = 3
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 8
            } else if indexPath == selectedColorPath {
                cell.layer.borderColor = colors[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.layer.borderWidth = 3
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 8
                selectedColorPath = nil
                selectedColor = colors[indexPath.item]
            } else {
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CreateTrackerController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 5
        let availableWidth = collectionView.bounds.width - (5 * spacing)
        let width = availableWidth / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
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
