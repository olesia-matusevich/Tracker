//
//  DataProvider.swift
//  Tracker
//
//  Created by Alesia Matusevich on 28/03/2025.
//

import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
    func reloadCollectionView()
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> TrackerCD?
    func nameSection(_ section: Int) -> String?
    func addTracker(_ record: Tracker, category: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
    func filteredTrackers(date: Date, title: String?)
}

// MARK: - DataProvider

final class DataProvider: NSObject {

    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: TrackerDataStore
    private var insertedIndexes: [IndexPath]
    private var deletedIndexes: [IndexPath]
    private var insertedSections: IndexSet
    private var deletedSections: IndexSet
   
    
    private var newSectionIndex: Int = 0
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {

        let fetchRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "categories.name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "categories.name",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
       
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("[DataProvider - fetchedResultsController] Ошибка при создании FRC: \(error.localizedDescription)")
        }
        return fetchedResultsController
    }()
    
    init(_ dataStore: TrackerDataStore, delegate: DataProviderDelegate) throws {
        guard let context = dataStore.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.dataStore = dataStore
        self.insertedIndexes = []
        self.deletedIndexes = []
        self.insertedSections = IndexSet()
        self.deletedSections = IndexSet()
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCD? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func nameSection(_ section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }

    func addTracker(_ record: Tracker, category: String) throws {
        do {
            try dataStore.addNewTracker(record, category: category)
            try fetchedResultsController.performFetch()
        } catch {
            print("[DataProvider - addTracker()] Ошибка при создании трекера: \(error.localizedDescription)")
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let record = fetchedResultsController.object(at: indexPath)
        do {
            try dataStore.delete(record)
        } catch {
            print("[DataProvider - deleteTracker()] Ошибка при удалении трекера: \(error.localizedDescription)")
        }
    }
    
    func filteredTrackers(date: Date, title: String?){
        let calendar = Calendar.current
        var numberWeekDay = calendar.component(.weekday, from: date)
        if numberWeekDay == 1 {
            numberWeekDay = 6
        } else {
            numberWeekDay -= 2
        }
        let filterWeekDay = daysOfWeek[numberWeekDay]
        
        var predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", filterWeekDay)
        
        if let title = title, !title.isEmpty {
            let filterText = title.lowercased()
            predicate = NSPredicate(format: "schedule CONTAINS[cd] %@ AND name CONTAINS[cd] %@", filterWeekDay, filterText)
        }
        
        NSFetchedResultsController<TrackerCD>.deleteCache(withName: fetchedResultsController.cacheName)
        
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async {
                self.delegate?.reloadCollectionView()
            }
        }
        catch {
            print("[DataProvider - filteredTrackers()] Ошибка при фильтрации: \(error.localizedDescription)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                insertedSections: insertedSections,
                deletedSections: deletedSections
            )
        )
        insertedIndexes = []
        deletedIndexes = []
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes.append(indexPath)
            }
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            deletedSections.insert(sectionIndex)
        case .insert:
            insertedSections.insert(sectionIndex)
        default:
            break
        }
    }
}
