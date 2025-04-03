//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Alesia Matusevich on 25/03/2025.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    convenience init() {
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
    
    func addNewTrackerCategory(_ tracker: TrackerCD, category: String) throws {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", category)
                do {
                    let existingCategories = try context.fetch(fetchRequest)
                    if let existingCategory = existingCategories.first {
                        existingCategory.addToTrackers(tracker)
                    } else {
                        let categoryCoreData = TrackerCategoryCD(context: context)
                        categoryCoreData.name = category
                        categoryCoreData.addToTrackers(tracker)
                        //try context.save()
                    }
                } catch {
                    print("[TrackerCategoryStore - addNewTrackerCategory()] Ошибка при создании категории: \(error.localizedDescription)")
                }
            }
        }
    }
}

