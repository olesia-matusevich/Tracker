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
    
    
    // этот вариант инициализации был приведен у нас учебнике как правильный
//    Спринт 15/24: 15 → Тема 4/7: Context → Урок 3/4 :
//    "3.2 Добавьте convenience init(), который вызывает init(context:), получая контекст из AppDelegate. Например, так:
//    (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext"
    
//    если не использовать этот вариант, то мне нужно в TreckerViewController получать context и передавать его дальше по цепочке?
    
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

