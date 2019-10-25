//
//  Database.swift
//  CloudKit_KiloLoco
//
//  Created by Lucas Costa  on 08/10/19.
//  Copyright © 2019 LucasCosta. All rights reserved.
//

import Foundation
import CloudKit

protocol DatabaseDelegate : AnyObject {
    func didFinishloadingData(records : [CKRecord])
    func didAddRecord(record : CKRecord)
    func newRecord(record : CKRecord)
    func deleteRecord(recordID : CKRecord.ID)
}

class Database {
    
    private var database : CKDatabase
    private weak var delegate : DatabaseDelegate?
    private(set) var cities : [CKRecord]?
    
    init(_ delegate : DatabaseDelegate) {
        self.database = CKContainer(identifier: "iCloud.com.LucasCosta.CloudKit-KiloLoco").publicCloudDatabase
        self.delegate = delegate
    }

    func saveRecord(_ person : Person) {
        
        let record = CKRecord(recordType: "Person")
        let reference = CKRecord.Reference(recordID: cities!.first!.recordID, action: .deleteSelf)
        
        record.setValue(person.name, forKey: "name")
        record.setValue(person.age, forKey: "age")
        record.setValue(person.height, forKey: "height")  
        record.setValue(reference, forKey: "city")
        
        self.database.save(record) { (record, error) in
            
            if let error = error as NSError? {
                print("ERROR -> \(error) - \(error.userInfo)")
                return
            }
            
            guard let new_record = record else {return}
            
            self.delegate?.didAddRecord(record: new_record)
        }
    }
    
    func queryRecord() {
        
        var records = [CKRecord]()
        
        guard let listId = self.cities?.first?.recordID else {return}
        
        let recordToMatch = CKRecord.Reference(recordID: listId, action: .none)
        
        let predicate = NSPredicate(format: "city == %@", recordToMatch)
        
        let query = CKQuery(recordType: "Person", predicate: predicate)
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        query.sortDescriptors = [sortDescriptor]
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { record in
            records.append(record)
        }
        
        operation.queryCompletionBlock = { [weak self] (cursor, error) in 
            
            if let error = error as NSError? {
                print("ERROR -> \(error) - \(error.userInfo)")
                return
            }
            
            DispatchQueue.main.async {
                self?.delegate?.didFinishloadingData(records: records)
            }            
        }
        
        self.database.add(operation)
    }
    
    private func createSubscription() {

        let predicate = NSPredicate(value: true)

        let querySubscription = CKQuerySubscription(recordType: "Person", predicate: predicate, options: .firesOnRecordDeletion)

        let notification = CKSubscription.NotificationInfo()

        notification.alertBody = "A Person was delete."
        notification.soundName = "default"
        notification.shouldBadge = true
        notification.alertLocalizationKey = "DELETE"

        querySubscription.notificationInfo = notification

        self.database.save(querySubscription) { (_, error) in
           if let error = error as NSError? {
               print("ERROR -> \(error) - \(error.userInfo)")
           }
        }
    }
    
    func fetchAllRecordCities() {
     
        let query = CKQuery(recordType: "City", predicate: NSPredicate(value: true))
        
        self.database.perform(query, inZoneWith: nil) { [unowned self] (records, error) in
            if let error = error as NSError? {
                print("Error -> \(error) - \(error.userInfo)")
                return
            }
                                
            guard let records = records else {return}
            self.cities = records
            self.queryRecord()
        }
    }
    
    func fetchRecordFromDatabase(recordID : CKRecord.ID) {
    
        self.database.fetch(withRecordID: recordID) { [unowned self] (record, error) in
            
            if let error = error as NSError? {
                print("Error -> \(error) - \(error.userInfo)")
            }
            
            guard let record = record else {return}
            
            self.delegate?.newRecord(record: record)
        }
    }
    
    func deleteRecordFromDatabase(recordID : CKRecord.ID) {
        
        self.database.delete(withRecordID: recordID) { [unowned self] (record, error) in
            
            if let error = error as NSError? {
                print("ERROR - \(error) - \(error.userInfo)")
                return
            }
            
            if let recordID = record {
                self.delegate?.deleteRecord(recordID: recordID)
                print("Delete sucessfully")

            } else {
                print("Don't delete")
            }
                
        }
        
    }
}
