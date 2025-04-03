//
//  TrackerStore.swift
//  Tracker
//
//  Created by Alesia Matusevich on 25/03/2025.
//

import UIKit
import CoreData

protocol TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func addNewTracker(_ tracker: Tracker, category: String) throws
    func delete(_ record: NSManagedObject) throws
}

final class TrackerStore: TrackerDataStore {
    
    private let context: NSManagedObjectContext
    let trackerCategoryStore = TrackerCategoryStore()
    
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
    
    func addNewTracker(_ tracker: Tracker, category: String) throws {
        try performSync { context in
            Result {
                let trackerCoreData = TrackerCD(context: context)
                trackerCoreData.id = tracker.id
                trackerCoreData.name = tracker.name
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.color = tracker.color
                
                if ((tracker.schedule?.isEmpty) != nil){
                    var daysSchedule: String = ""
                    for day in tracker.schedule ?? [] {
                        daysSchedule += day.rawValue + ","
                    }
                    trackerCoreData.schedule = daysSchedule
                } else {
                    trackerCoreData.schedule = nil
                }
                do {
//                    print("трекер добавлен \(String(describing: trackerCoreData.name))")
                    try trackerCategoryStore.addNewTrackerCategory(trackerCoreData, category: category)
                    try context.save()
                } catch {
                    print("[TrackerStore - addNewTracker()] Ошибка при создании трекера:: \(error), \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
    
    func delete(_ record: NSManagedObject) throws {
        //TODO: доделать функцию для удаления
    }
}

