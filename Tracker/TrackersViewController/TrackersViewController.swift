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
        label.text = NSLocalizedString("trackersTitle", comment: "title for trackers screen")
        label.textColor = .castomBlack
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
        button.tintColor = .castomBlack
        button.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let sBar = UISearchBar()
        sBar.placeholder = NSLocalizedString("search", comment: "")
        sBar.translatesAutoresizingMaskIntoConstraints = false
        let textCancel = NSLocalizedString("cancel", comment: "")
        sBar.setValue(textCancel, forKey: "cancelButtonText")
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
        label.text = NSLocalizedString("trackers_screen_stub", comment: "stub if there are no trackers on the screen")
        label.textColor = .castomBlack
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 16
        button.backgroundColor = .castomBlue
        let buttonText = NSLocalizedString("filter", comment: "text for filter button")
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(filterButtonTappet), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var currentDate: Date = Date()
    private var collectionView: UICollectionView!
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var filterViewController: FilterViewController?
    private let analyticsService = AnalyticsService()
    
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            try dataProvider = DataProvider(trackerStore, delegate: self)
            guard let dataProvider else { return nil }
            return dataProvider
        } catch {
            print("[TrackersViewController - dataProvider] Ошибка при создании dataProvider: \(error.localizedDescription)")
            return nil
        }
    }()
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupСonstraints()
        
        view.backgroundColor = .castomBackground
        
        searchBar.delegate = self
        datePicker.date = Date()
        
        setupDateLabel()
        setupCollectionView()
        setupFilterButton()
        //updateFilteredTrackers()
        setupPlaceholderImage(emptySearch: false)
        
        analyticsService.report(event: Event.open, screen: Screen.main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, screen: .main)
    }
    // MARK: - @objc Methods
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: datePicker.date)
        currentDate = datePicker.date
        updateFilteredTrackers()
    }
    
    @objc func didTapButton() {
        let selectTrackerVC = SelectTrackerTypeController()
        analyticsService.report(event: .click, screen: .main, item: .add_track)
        present(selectTrackerVC, animated: true, completion: nil)
    }
    
    @objc private func filterButtonTappet() {
        guard let filterViewController = filterViewController else {
            filterViewController = FilterViewController()
            if let filterViewController = filterViewController {
                self.bind()
                present(filterViewController, animated: true)
            }
            return
        }
        analyticsService.report(event: .click, screen: .main, item: .filter)
        present(filterViewController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupDateLabel() {
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.locale = Locale.current
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    private func updateFilteredTrackers() {
        dataProvider?.filterByDate(datePicker.date)
        setupPlaceholderImage(emptySearch: true)
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
        collectionView.backgroundColor = .castomBackground
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
    
    private func setupPlaceholderImage(emptySearch: Bool){
        guard (dataProvider != nil) else { return }
        if dataProvider?.numberOfSections ?? 0 > 0 {
            hideEmptyStub()
            filterButton.isHidden = false
        } else {
            let currentFilter = UserDefaults.standard.string(forKey: "filter")
            if currentFilter == nil || currentFilter == FilterModes.all.rawValue {
                filterButton.isHidden = true
            } else {
                filterButton.isHidden = false
            }
            setupNoTrackersImage(emptySearch: emptySearch)
        }
    }
    
    private func setupNoTrackersImage(emptySearch: Bool) {
        noTrackersImage.isHidden = false
        noTrackersLabel.isHidden = false
        
        if emptySearch {
            noTrackersImage.image  = UIImage(named: "emptySearchImage")
            noTrackersLabel.text = NSLocalizedString("trackers_empty_search", comment: "")
        } else {
            noTrackersImage.image  = UIImage(named: "noTrackersImage")
            noTrackersLabel.text = NSLocalizedString("trackers_screen_stub", comment: "")
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
    
    private func hideEmptyStub(){
        noTrackersImage.isHidden = true
        noTrackersLabel.isHidden = true
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
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bind() {
        guard let filterViewController = filterViewController else { return }
        
        filterViewController.filterSelected = { [weak self] in
            guard let self = self else { return }
            self.dataProvider?.filterByDate(currentDate)
            DispatchQueue.main.async {
                self.setupPlaceholderImage(emptySearch: true)
                let mode = UserDefaults.standard.string(forKey: "filter")
                if mode == FilterModes.today.rawValue {
                    self.datePicker.date = Date()
                    self.setupDateLabel()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider?.numberOfSections ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider?.numberOfItemsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell
        else { return UICollectionViewCell() }
        
        guard let tracker = dataProvider?.object(at: indexPath) else { return UICollectionViewCell() }
        
        cell.nameLabel.text = tracker.name
        cell.emojiLabel.text = tracker.emoji
        
        let trackerColor = tracker.color as? UIColor ?? UIColor.trackerColor01
        cell.containerView.backgroundColor = trackerColor
        
        guard let trackerId = tracker.id else { return UICollectionViewCell() }
        cell.trackerID = tracker.id
        cell.isPinned = tracker.isPinned
        
        let isSelected = trackerRecordStore.trackerIsCompleted(TrackerRecord(id: trackerId, date: currentDate))
        cell.completeButton.isSelected = isSelected
        if isSelected {
            cell.completeButton.backgroundColor = trackerColor.withAlphaComponent(0.3)
        } else {
            cell.completeButton.backgroundColor = trackerColor
        }
        let countRecords = trackerRecordStore.amountOfRecords(for: trackerId)
        cell.daysCountLabel.text = cell.daysString(amoumnt: countRecords)
        
        cell.delegate = self
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.containerView.addInteraction(interaction)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.reuseIdentifier, for: indexPath) as? TrackerHeader
            else { return UICollectionReusableView() }
            let nameSection = dataProvider?.nameSection(indexPath.section)
            header.titleLabel.text = nameSection
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
        let categoryName = category.name
        guard let tracker = category.trackers?.first else { return }
        do {
            try dataProvider?.addTracker(tracker, category: categoryName)
        } catch {
            print("[TrackersViewController - addTracker()] Ошибка при создании трекера: \(error.localizedDescription)")
        }
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func countRecordsByID(id: UUID) -> Int {
        let countRecords = trackerRecordStore.amountOfRecords(for: id)
        return countRecords
    }
    
    func trackerCompleated(id: UUID) {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        do {
            try trackerRecordStore.changeState(for: trackerRecord)
        } catch {
            print("[TrackersViewController - trackerCompleated()] Ошибка при сохранении выполненного трекера: \(error.localizedDescription)")
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

extension TrackersViewController: DataProviderDelegate {
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.reloadData()
        setupPlaceholderImage(emptySearch: false)
    }
}

extension TrackersViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    
        guard let containerView = interaction.view else {
            print("ERROR: interaction.view is nil")
            return nil
        }
        var targetCell: TrackerCell?
        var currentView: UIView? = containerView
        while currentView != nil {
            if let cell = currentView as? TrackerCell {
                targetCell = cell
                break
            }
            currentView = currentView?.superview
        }
        
        guard let cell = targetCell else {
            print("ERROR: Could not find TrackerCell in superview hierarchy.")
            return nil
        }
        let locationInCollectionView = collectionView.convert(location, from: containerView)
        
        guard let indexPath = collectionView.indexPathForItem(at: locationInCollectionView) else {
            print("ERROR: Could not find indexPath for location: \(locationInCollectionView)")
            return nil
        }
        guard let trackerCD = dataProvider?.object(at: indexPath) else {
            print("ERROR: No trackerCD found at indexPath: \(indexPath)")
            return nil
        }
        guard let tracker: Tracker = convertToTracker(trackerCD) else {
            print("ERROR: Could not convert TrackerCD to Tracker for indexPath: \(indexPath)")
            return nil
        }
        let numberOfDays = cell.daysCountLabel.text ?? ""

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            let action1 = UIAction(title: tracker.isPinned == true ? "Открепить" : "Закрепить") {
                [weak self] id in
                guard let self = self else { return }
                self.pinTracker(with: tracker.id)
            }
            
            let action2 = UIAction(title: "Редактировать") { [weak self] _ in
                guard let self = self else { return }
                analyticsService.report(event: .click, screen: .main, item: .edit)
                self.editTracker(tracker: tracker, numberOfDays: numberOfDays)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                analyticsService.report(event: .click, screen: .main, item: .delete)
                self.showDeleteAlert(for: tracker.id)
            }
            return UIMenu(children: [action1, action2, deleteAction])
        }
    }
    
    private func convertToTracker(_ record: TrackerCD) -> Tracker? {
        guard let title = record.name,
              let emoji = record.emoji,
              let color = record.color,
              let category = record.categories,
              let id = record.id,
              let originalCategory = record.originalCategory
        else { return nil }
        
        var schedule: [ScheduleItems]?
        
        if let scheduleCD = record.schedule {
            schedule = convertStringToScheduleItems(input: scheduleCD)
        } else {
            schedule = nil
        }
        let isPinned: Bool = record.isPinned
        
        return Tracker(
            id: id,
            name: title,
            color: color as? UIColor ?? UIColor.trackerColor01,
            emoji: emoji,
            schedule: schedule,
            isPinned: isPinned,
            originalCategory: originalCategory
        )
    }
    
    func convertStringToScheduleItems(input: String) -> [ScheduleItems] {
        
        let dayStrings = input.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        var scheduleItems: [ScheduleItems] = []
        
        for dayString in dayStrings {
            if let scheduleItem = ScheduleItems(rawValue: dayString) {
                scheduleItems.append(scheduleItem)
            }
        }
        return scheduleItems
    }
    
    private func pinTracker(with id: UUID) {
        self.dataProvider?.pinTracker(with: id)
        self.reloadCollectionView()
    }
    
    private func deleteTracker(with id: UUID) {
        self.dataProvider?.deleteTracker(with: id)
    }
    
    private func showDeleteAlert(for trackerId: UUID) {
        let deleteText = NSLocalizedString("delete", comment: "delete tracker")
        let alertMessage = NSLocalizedString("deleteMessage", comment: "warning message about tracker deleting")
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: deleteText, style: .destructive, handler: { [weak self] _ in
            self?.deleteTracker(with: trackerId)
        })
        )
        let cancelText = NSLocalizedString("cancel", comment: "cancel tracker deletion")
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func editTracker(tracker: Tracker, numberOfDays: String) {
        let needSchedule: Bool = tracker.schedule != nil
        let editableTrackerController = CreateTrackerController(needSchedule: needSchedule, editableTracker: tracker, numberOfDays: numberOfDays)
        editableTrackerController.createTrackerDelegate = self
        
        editableTrackerController.trackerEditingCanceled = { [weak self] in
            self?.dismiss(animated: true)
        }
        editableTrackerController.trackerEdited = { [weak self] tracker, category in
            self?.dataProvider?.editRecord(tracker: tracker, category: category) { success in
                DispatchQueue.main.async {
                    if success {
                        self?.collectionView.reloadData()
                    }
                    self?.dismiss(animated: true)
                }
            }
        }
        present(editableTrackerController, animated: true)
    }
}
