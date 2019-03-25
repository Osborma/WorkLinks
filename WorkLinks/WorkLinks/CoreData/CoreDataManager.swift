//
//  CoreDataManager.swift
//  WorkLinks
//
//  Created by Maximilian Osborne on 19/03/2019.
//  Copyright © 2019 KeyTree. All rights reserved.
//

import CoreData

struct CoreDataManager{

    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "coreDataModel")
        container.loadPersistentStores { (storeDescription, err) in
            if let err = err {
                fatalError("loading of store failed: \(err)")
            }
        }
        return container
    }()

    func fetchContacts() -> [Contact] {
        let context =  persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")

        do {
            let contacts = try context.fetch(fetchRequest)
            return contacts

        } catch let fetchErr {
            print("Failed to fetch contacts:", fetchErr)
            return []
        }
    }

    func handleReset() -> Bool {
        let context = persistentContainer.viewContext

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest:
            Contact.fetchRequest())

        do {
            try context.execute(batchDeleteRequest)
            return true
        } catch let delErr {
            print("Failed to delete objects from Core Data:", delErr)
            return false
        }
    }

    func actionAction(actionName: String, contact: Contact, deadline: Date? = nil, actionType: String) -> (action: Action?, error: Error?) {
        let context = persistentContainer.viewContext

        let action =
            NSEntityDescription.insertNewObject(forEntityName: "Action",
                                                into: context) as! Action

        action.contact = contact

        action.setValue(actionName, forKey: "name")

        action.type = actionType

        if deadline != nil {
            let actionInformation =
                NSEntityDescription.insertNewObject(forEntityName: "ActionInformation",
                                                    into: context) as! ActionInformation
            actionInformation.deadline = deadline
            action.actionInformation = actionInformation
        }

        do {
            try context.save()
            return (action: action, error: nil)
        } catch let saveErr {
            print("Failed to create action:", saveErr)
            return (action: nil, error: saveErr)
        }
    }
    
}
