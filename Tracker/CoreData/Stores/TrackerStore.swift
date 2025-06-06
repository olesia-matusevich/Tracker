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
    func deleteTracker(with id: UUID)
    func editRecord(tracker: Tracker, category: String, completion: @escaping (Bool) -> Void)
    func findCategoryTitle(by id: UUID) -> String
    func pinTracker(with id: UUID)
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
                trackerCoreData.isPinned = false
                trackerCoreData.originalCategory = category
                
                if ((tracker.schedule?.isEmpty) != nil){
                    var daysSchedule: String = ""
                    for day in tracker.schedule ?? [] {
                        daysSchedule += day.rawValue + ","
                    }
                    trackerCoreData.schedule = daysSchedule
                } else {
                    trackerCoreData.schedule = nil
                }
                trackerCoreData.categories = try? findCategory(by: category, in: context)
                
                do {
                    try context.save()
                } catch {
                    print("[TrackerStore - addNewTracker()] Ошибка при создании трекера: \(error), \(error.localizedDescription)")
                }
            }
        }
    }
    
    func editRecord(tracker: Tracker, category: String, completion: @escaping (Bool) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = TrackerCD.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as NSUUID)
            
            do {
                if let editableTracker = try self.context.fetch(fetchRequest).first {
                    editableTracker.color = tracker.color
                    editableTracker.emoji = tracker.emoji
                    if ((tracker.schedule?.isEmpty) != nil){
                        var daysSchedule: String = ""
                        for day in tracker.schedule ?? [] {
                            daysSchedule += day.rawValue + ","
                        }
                        editableTracker.schedule = daysSchedule
                    } else {
                        editableTracker.schedule = nil
                    }
                    if editableTracker.categories?.name == PinnedCategory.title {
                        editableTracker.isPinned = tracker.isPinned
                    } else {
                        editableTracker.isPinned = false
                    }
                    editableTracker.name = tracker.name
                    editableTracker.originalCategory = category
                    editableTracker.categories = try? findCategory(by: category, in: context)
                    
                    try self.context.save()
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
                print("Ошибка редактирования: \(error)")
            }
        }
    }
    
    private func findCategory(by name: String, in context: NSManagedObjectContext) throws -> TrackerCategoryCD? {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        let category = try? context.fetch(request)
        return category?.first
    }
    
    func pinTracker(with id: UUID) {
        let fetchRequest = TrackerCD.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as NSUUID)
        fetchRequest.predicate = predicate
        do {
            let object = try context.fetch(fetchRequest)
            guard let tracker = object.first else { return }
            guard let category = tracker.originalCategory else {
                print("[TrackerStore - pinTracker()] - Отсутствует оригинальная категория.")
                return
            }
            if tracker.isPinned  {
                tracker.isPinned.toggle()
                let request = TrackerCategoryCD.fetchRequest()
                request.predicate = NSPredicate(format: "name == %@", category)
                
                guard let previousCategory = try? context.fetch(request).first else {
                    print("[TrackerStore - pinTracker()] - Не удалось найти предыдущую категорию")
                    return
                }
                tracker.categories = previousCategory
            } else {
                tracker.isPinned.toggle()
                //tracker.isPinned = true
                let request = TrackerCategoryCD.fetchRequest()
                request.sortDescriptors =  [NSSortDescriptor(key: "sorting", ascending: true)]
                request.predicate = NSPredicate(format: "name == %@", PinnedCategory.title)
                
                if let pinnedCategory = try? context.fetch(request).first {
                    tracker.categories = pinnedCategory
                } else {
                    try trackerCategoryStore.addRecord(with: PinnedCategory.title, sorting: 0)
                    tracker.categories = try? findCategory(by: PinnedCategory.title, in: context)
                }
            }
            try context.save()
        }
        catch {
            print("[TrackerStore - pinTracker()] - Не получилось закрепить трекер.")
        }
    }
    
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
    
    func delete(_ record: NSManagedObject) throws {
        do {
            context.delete(record)
            try context.save()
        }
        catch {
            print("[\(#function)] - Ошибка удаления трекера.")
        }
    }
    
    func deleteTracker(with id: UUID) {
        let fetchRequest = TrackerCD.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as NSUUID)
        fetchRequest.predicate = predicate
        do {
            let object = try context.fetch(fetchRequest)
            if let tracker = object.first {
                context.delete(tracker)
            }
            try context.save()
        }
        catch {
            print("[\(#function)] - Ошибка удаления трекера.")
        }
    }
    
    func findCategoryTitle(by id: UUID) -> String {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        
        if let trakcer = try? context.fetch(request) {
            return trakcer.first?.categories?.name ?? ""
        }
        return ""
    }
}

