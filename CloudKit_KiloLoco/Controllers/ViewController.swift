//
//  ViewController.swift
//  CloudKit_KiloLoco
//
//  Created by Lucas Costa  on 08/10/19.
//  Copyright © 2019 LucasCosta. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var database : Database = {
        let database = Database(self)
        database.fetchAllRecordCities()
        return database
    }()
    
    private var people = [CKRecord]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.database.queryRecord()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView(notification:)), name: Notification.Name("cloudKit.newRecord"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView(notification:)), name: Notification.Name("cloudKit.deleteRecord"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    @IBAction func addName(_ sender: Any) {
        self.registerPerson()
    }
    
    private func registerPerson() {
        
        let alert = UIAlertController(title: "Register", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (name) in
            name.placeholder = "Name"
        }

        alert.addTextField { (age) in
           age.placeholder = "Age"
        }
        
        alert.addTextField { (height) in
           height.placeholder = "Height"
        }
                
        let save = UIAlertAction(title: "SAVE", style: .default) { (_) in
            
            guard let name = alert.textFields?[0].text else {return}
            guard let age = alert.textFields?[1].text else {return}
            guard let height = alert.textFields?[2].text else {return}
            
            let person = Person(name : name, age : Int(age)!, height : Float(height)!)
            self.database.saveRecord(person)
        }
        
        let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func updateTableView(notification : NSNotification) {
        
        guard let recordID = notification.userInfo?["recordID"] as? CKRecord.ID else {return}
        
        guard let type = notification.userInfo?["type"] as? String else {return}
        
        if type == "Create" {
            self.database.fetchRecordFromDatabase(recordID: recordID)   
        } else {
            self.database.deleteRecordFromDatabase(recordID: recordID)
        }
    }
    

}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonTableViewCell
        
        cell.person = self.people[indexPath.row]
        
        return cell
    }    
}

extension ViewController : DatabaseDelegate {
    
    func didAddRecord(record: CKRecord) {
        DispatchQueue.main.async {
            let index = IndexPath(row: self.people.count, section: 0)
            self.people.append(record)
            self.tableView.insertRows(at: [index], with: .automatic)
        }
    }
    
    func didFinishloadingData(records: [CKRecord]) {
        DispatchQueue.main.async {           
            self.people = records
            self.tableView.reloadData()
        }
    }
    
    func newRecord(record: CKRecord) {
        
        DispatchQueue.main.async {
            self.people.append(record)
            self.tableView.insertRows(at: [IndexPath(row: self.people.count-1, section: 0)], with: .fade)
        }
    }
    
    func deleteRecord(recordID: CKRecord.ID) {
     
        let id = self.people.firstIndex { (record) -> Bool in
            return record.recordID == recordID
        }
        
        if let index = id {
            DispatchQueue.main.async {
                self.people.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            self.database.deleteRecordFromDatabase(recordID: self.people[indexPath.row].recordID)
        }
    }
}
