//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit
import CoreData


class TaskListViewController: UITableViewController {
    
    private var taskList: [Task] = []
    private let cellID = "task"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StorageManager.shared.fetchData { taskList in
            self.taskList = taskList
        }
        
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        StorageManager.shared.saveContext()
        StorageManager.shared.fetchData { taskList in
            self.taskList = taskList
        }
        
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self]_ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            StorageManager.shared.save(task) { task in
                self.taskList.append(task)
                let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
                tableView.insertRows(at: [cellIndex], with: .automatic)
                
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            StorageManager.shared.delete(for: task)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // получаю выбранную по тапу задачу
        let task = taskList[indexPath.row]
        // Создаем аллерт контроллер
        let alertController = UIAlertController(title: "Edit task", message: "What do you want to do?", preferredStyle: .alert)
        // Добавляю текстовое поле в аллерт , содержащее название задачи
        alertController.addTextField { textField in
            textField.text = task.title
        }
        // Добавляем кнопку "Cancel" и "Save" в аллерт контроллера
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            // Получаем новое значение названия задачи из текстового поля
            guard let newTitle = alertController.textFields?.first?.text else { return }
            // вызываю метод редактирования
            StorageManager.shared.edit(for: task, newTitle: newTitle)
            // перезагружаю данные в ячейке
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }))
        // отображаю аллерт
        present(alertController, animated: true, completion: nil)
    }
}





