//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Alesia Matusevich on 03/05/2025.
//

import Foundation

typealias Index = Int
typealias Binding<T> = (T) -> Void

protocol CategoriesViewModelProtocol: AnyObject {
    var selectedCategoryTitle: String? { get }
    var visibleDataChanged: Binding<TrackerStoreUpdate>? { get set }
    func numberOfCategories() -> Int
    func addRecord(with title: String)
    func category(at index: Index) -> CategoryViewModel
    func selectCategory(at index: Index)
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
    
    var visibleDataChanged: Binding<TrackerStoreUpdate>?
    
    var selectedCategoryTitle: String? {
        guard let selectedIndexPath = selectedIndex else { return nil }
        return title(at: selectedIndexPath)
    }
    
    private var selectedIndex: Index?
    
    private lazy var categoryDataProvider: CategoryDataProviderProtocol = {
        let store = TrackerCategoryStore.shared
        store.delegate = self
        return store
    }()
    
    func selectCategory(at index: Index) {
        selectedIndex = index
    }
    
    func addRecord(with title: String) {
        do {
            try categoryDataProvider.addRecord(with: title, sorting: 1)
        }
        catch {
            print("[CategoriesViewModel - addRecord()] - Ошибка добавления новой записи.")
        }
    }
    
    func title(at index: Index) -> String {
        guard let trackerCategory = categoryDataProvider.object(at: index) else {
            print("[CategoriesViewModel - title()] - Ошибка получения заголовка категории.")
            return ""
        }
        return trackerCategory.name
    }
    
    func isSelected(at index: Index) -> Bool {
        return selectedIndex == index
    }
    
    func category(at index: Index) -> CategoryViewModel {
        let title = title(at: index)
        let isSelected = isSelected(at: index)
        let categoryCellViewModel = CategoryViewModel(title: title, isSelected: isSelected)
        
        return categoryCellViewModel
    }
    
    func numberOfCategories() -> Int {
        categoryDataProvider.numberOfRows
    }
}

//MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        guard let visibleDataChanged = visibleDataChanged else {
            print("[CategoriesViewModel - didUpdate()] - Ошибка: binding is nil")
            return
        }
        DispatchQueue.main.async {
            visibleDataChanged(update)
        }
    }
}
