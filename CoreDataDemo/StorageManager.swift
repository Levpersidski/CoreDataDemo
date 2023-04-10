//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Роман Бакаев on 07.04.2023.
//

import Foundation
import CoreData
import UIKit

class StorageManager {
    static let shared = StorageManager()

    private init() {}
    
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
   lazy var viewContext = persistentContainer.viewContext
    
    
    func fetchData(completion:([Task]) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
           let taskList = try viewContext.fetch(fetchRequest)
            completion(taskList)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    
    

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
     func save(_ taskName: String, completion:([Task]) -> Void) {
        let task = Task(context: viewContext) // создается обьект задачи на основе контекста
        task.title = taskName // передаем в тайтл значение из параметра 
         var taskList: [Task] = []
         taskList.append(task)
         completion(taskList)
       
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    func deleteCell (for row: Int) {
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let task = Task(context: viewContext)
                 var taskList: [Task] = []
                taskList.remove(at: row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
            }
        }
    }
    
}
