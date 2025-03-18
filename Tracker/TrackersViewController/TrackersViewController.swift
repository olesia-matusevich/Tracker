//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Alesia Matusevich on 04/03/2025.
//

import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Private properties
    
    private let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Трекеры"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        label.backgroundColor = .castomGrayDatePicker
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_Ru")
        picker.backgroundColor = .white
        picker.calendar.firstWeekday = 2
        let spacing: CGFloat = 16
        let width = view.frame.width - spacing * 2
        picker.frame = CGRect(x: spacing, y: 150, width: width, height: 325)
        picker.layer.cornerRadius = 13
        picker.layer.masksToBounds = true
        picker.date = Date()
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private let datePickerContainer = UIView()
    private lazy var dateFormatter = DateFormatter()
    
    private lazy var plusButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let sBar = UISearchBar()
        sBar.placeholder = "Поиск"
        sBar.translatesAutoresizingMaskIntoConstraints = false
        sBar.setValue("Отменить", forKey: "cancelButtonText")
        if let textField = sBar.value(forKey: "searchField") as? UITextField {
            textField.clearButtonMode = .never
        }
        sBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        return sBar
    }()
    
    private let noTrackersImage: UIImageView = {
        let view = UIImageView()
        var image: UIImage?
        image  = UIImage(named: "noTrackersImage")
        view.image = image
        return view
    }()
    
    private let noTrackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private var collectionView: UICollectionView!
    
    // тестовые данные
    private let tracker1 = Tracker(
        name: "Утренняя пробежка",
        emoji: "🏃‍♂️",
        schedule: [.Monday, .Wednesday, .Friday],
        color: .castomOrange
    )
    
    private let tracker2 = Tracker(
        name: "Чтение книги",
        emoji: "📚",
        schedule: [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday],
        color: .castomGreen
    )
    
    private let tracker3 = Tracker(
        name: "Медитация",
        emoji: "🧘‍♀️",
        schedule: [.Saturday, .Sunday],
        color: .castomRed
    )
    
    private lazy var categories: [TrackerCategory] = [
        TrackerCategory(name: "Здоровье и фитнес", trackers: [self.tracker1, self.tracker2 ]),
        TrackerCategory(name: "Умственные привычки", trackers: [self.tracker3]),
    ]
    
    private var visibleCategories: [TrackerCategory] = []
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupСonstraints()
        
        searchBar.delegate = self
        datePicker.date = Date()
        
        setupDateLabel()
        setupCollectionView()
        
        updateFilteredTrackers()
        
        if visibleCategories.isEmpty {
            setupNoTrackersImage(emptySearch: false)
        }
    }
    
    // MARK: - @objc Methods
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: datePicker.date)
        currentDate = datePicker.date
        updateFilteredTrackers()
    }
    
    @objc func didTapButton() {
        let selectTrackerVC = SelectTrackerTypeController()
        present(selectTrackerVC, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func setupDateLabel() {
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "dd.MM.yy"
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    private func updateFilteredTrackers() {
        let calendar = Calendar.current
        var numberWeekDay = calendar.component(.weekday, from: currentDate)
        if numberWeekDay == 1 {
            numberWeekDay -= 1
        } else {
            numberWeekDay -= 2
        }
        let filterWeekDay = daysOfWeek[numberWeekDay]
        let filterText = (searchBar.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                tracker.name.lowercased().contains(filterText)
                let dateCondition = tracker.schedule?.contains { weekDay in
                    weekDay.rawValue == filterWeekDay
                } == true
                return textCondition && dateCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                name: category.name,
                trackers: trackers
            )
        }
        if visibleCategories.isEmpty {
            setupNoTrackersImage(emptySearch: true)
        } else {
            hideEmptyStub()
        }
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        
        let sideInset: CGFloat = 16 // отступ слева
        let numberOfColumns: CGFloat = 2 // количество колонок
        let cellSpacing: CGFloat = 9 // расстояние между колонками
        let totalSpacing = cellSpacing + 2 * sideInset // общее количество отступов
        
        let cellWidth = (view.frame.width - totalSpacing) / numberOfColumns // ширина колонки
        
        layout.itemSize = CGSize(width: cellWidth, height: 148)
        layout.minimumInteritemSpacing = cellSpacing  // Расстояние между столбцами
        layout.minimumLineSpacing = 0      // Расстояние между строками
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 40)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.reuseIdentifier)
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 50),
        ])
    }
    
    private func setupNoTrackersImage(emptySearch: Bool) {
        noTrackersImage.isHidden = false
        noTrackersLabel.isHidden = false
        
        if emptySearch {
            noTrackersImage.image  = UIImage(named: "emptySearchImage")
            noTrackersLabel.text = "Ничего не найдено"
        } else {
            noTrackersImage.image  = UIImage(named: "noTrackersImage")
            noTrackersLabel.text = "Что будем отслеживать?"
        }
        
        [noTrackersImage, noTrackersLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            noTrackersImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noTrackersImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            noTrackersLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noTrackersLabel.topAnchor.constraint(equalTo: noTrackersImage.bottomAnchor, constant: 8),
        ])
    }
    
    private func setupViews() {
        [titleLabel, plusButton, searchBar, dateLabel, datePicker].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupСonstraints(){
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            plusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            plusButton.heightAnchor.constraint(equalToConstant: 42),
            plusButton.widthAnchor.constraint(equalToConstant: 42),
         
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 80),
            
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateLabel.heightAnchor.constraint(equalToConstant: 34),
            dateLabel.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        view.bringSubviewToFront(dateLabel)
    }
    
    private func hideEmptyStub(){
        noTrackersImage.isHidden = true
        noTrackersLabel.isHidden = true
    }
    
    // MARK: - Public Methods
    
    func countRecordsByID(id: UUID) -> Int {
        let count = completedTrackers.filter { $0.id == id }.count
        return count
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as! TrackerCell
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.nameLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        let countRecords = countRecordsByID(id: tracker.id)
        cell.daysCountLabel.text = cell.daysString(amoumnt: countRecords)
        cell.completeButton.backgroundColor = tracker.color
        cell.completeButton.isSelected = false
        cell.containerView.backgroundColor = tracker.color
        cell.trackerID = tracker.id
        
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.reuseIdentifier, for: indexPath) as! TrackerHeader
            header.titleLabel.text = visibleCategories[indexPath.section].name
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - CreateTrackerProtocol

extension TrackersViewController: CreateTrackerProtocol {
    func cancelCreateTracker() {
        self.dismiss(animated: true)
    }
    
    func addTracker(for category: TrackerCategory) {
        var newCategories = categories
        if let index = newCategories.firstIndex(where: {$0.name == category.name}) {
            let updatedCategory = TrackerCategory(
                name: category.name,
                trackers: newCategories[index].trackers + category.trackers
            )
            newCategories[index] = updatedCategory
        } else {
            newCategories.append(category)
        }
        categories = newCategories
        updateFilteredTrackers()
        //collectionView.reloadData()
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCompleated(id: UUID) {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        if completedTrackers.contains(trackerRecord) {
            completedTrackers.remove(trackerRecord)
        } else {
            completedTrackers.insert(trackerRecord)
        }
    }
    
    func checkDate() -> Bool { //проверка, что трекер не будет отмечен как выполненный будущим числом
        if datePicker.date > Date() {
            return false
        } else {
            return true
        }
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        animateCancelButton(visible: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        animateCancelButton(visible: false)
        updateFilteredTrackers()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateFilteredTrackers()
    }
    
    private func animateCancelButton(visible: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.searchBar.showsCancelButton = visible
            self.searchBar.layoutIfNeeded()
        })
    }
}


