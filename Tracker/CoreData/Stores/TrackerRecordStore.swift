//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Alesia Matusevich on 25/03/2025.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    // MARK: - Private Methods
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    // MARK: - Public Methods
    
    func changeState(for record: TrackerRecord) throws {
        try performSync { context in
            Result {
                let trackerRecordFetch = TrackerRecordCD.fetchRequest()
                trackerRecordFetch.predicate = NSPredicate(format: "id == %@ AND date == %@", record.id as NSUUID, record.date as NSDate)
                let results = try context.fetch(trackerRecordFetch)
                if results.isEmpty {
                    let trackerRecord = TrackerRecordCD(context: context)
                    trackerRecord.id = record.id
                    trackerRecord.date = record.date
                }
                else {
                    results.forEach { result in
                        context.delete(result)
                    }
                }
                try context.save()
            }
        }
    }
    
    func trackerIsCompleted(_ record: TrackerRecord) -> Bool {
        do {
            return try performSync { context in
                Result {
                    let trackerRecordFetch = TrackerRecordCD.fetchRequest()
                    trackerRecordFetch.predicate = NSPredicate(format: "id == %@ AND date == %@", record.id as NSUUID, record.date as NSDate)
                    let result = try context.fetch(trackerRecordFetch)
                    
                    if result.isEmpty {
                        return false
                    }
                    else {
                        return true
                    }
                }
            }
        }
        catch {
            return false
        }
    }
    
    func amountOfRecords(for id: UUID) -> Int {
        do {
            return try performSync { context in
                Result {
                    let trackerRecordFetch = TrackerRecordCD.fetchRequest()
                    trackerRecordFetch.resultType = .countResultType
                    trackerRecordFetch.predicate = NSPredicate(format: "id == %@", id as NSUUID)
                    let result = try context.count(for: trackerRecordFetch)
                    return result
                }
            }
        }
        catch {
            print("[TrackerRecordStore - amountOfRecords(for:)] Ошибка при подсчете выполненных трекеров: \(error.localizedDescription)")
            return 0
        }
    }
}

