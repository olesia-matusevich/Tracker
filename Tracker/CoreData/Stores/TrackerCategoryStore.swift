//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Alesia Matusevich on 25/03/2025.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol CategoryDataProviderProtocol: AnyObject {
    var numberOfRows: Int { get }
    func object(at index: Index) -> TrackerCategory?
    func addRecord(with title: String) throws
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    
    static let shared = TrackerCategoryStore()
    
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCategoryCD> = {
          
          let fetchRequest = TrackerCategoryCD.fetchRequest()
          fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
          
          let fetchResultController = NSFetchedResultsController(
              fetchRequest: fetchRequest,
              managedObjectContext: context,
              sectionNameKeyPath: nil,
              cacheName: nil
          )
          fetchResultController.delegate = self
          try? fetchResultController.performFetch()
          
          return fetchResultController
      }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
}

extension TrackerCategoryStore: CategoryDataProviderProtocol {
    func addRecord(with title: String) throws {
        try performSync { context in
            Result {
                let trackerCategoryCD = TrackerCategoryCD(context: context)
                trackerCategoryCD.name = title
                try context.save()
            }
        }
    }
    
    func object(at index: Index) -> TrackerCategory? {
        
        guard let numberOfCategories = fetchedResultController.fetchedObjects?.count,
              index < numberOfCategories else {
            print("[TrackerCategoryStore - object()] Ошибка при получении номера категории")
            return nil
        }
        let categoryData = fetchedResultController.object(at: IndexPath(row: index, section: 0))
        guard let title = categoryData.name else {
            print("[TrackerCategoryStore - object()] Ошибка при получении имени категории")
            return nil
        }
        let trackerCategory = TrackerCategory(name: title, trackers: nil)
        return trackerCategory
    }
    
    var numberOfRows: Int {
        fetchedResultController.fetchedObjects?.count ?? 0
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            insertedSections: [],
            deletedSections: [])
        )
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes.append(indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
            if let newIndexPath = newIndexPath {
                insertedIndexes.append(newIndexPath)
            }
        default:
            break
        }
    }
}
