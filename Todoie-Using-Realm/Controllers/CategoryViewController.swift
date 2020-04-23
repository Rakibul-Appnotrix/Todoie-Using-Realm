//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Rakibul Hasan on 13/4/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadCategory()
    }
    
    //MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var alertTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if alertTextField.text != ""{
                let newCategory = Category()
                newCategory.name = alertTextField.text!
                newCategory.bgColor = UIColor.randomFlat().hexValue()
                
                self.save(category: newCategory)
                
                self.tableView.insertRows(at: [IndexPath(row: (self.categoryArray?.count ?? 1) - 1, section: 0)], with: .bottom)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
            alert.removeFromParent()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add a new category"
            
            alertTextField = textField
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    
    private func save(category: Category){
        
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error while saving category \(error)")
        }
    }
    
    private func loadCategory(){
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row]{
            
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error while deleting, \(error)")
            }
        }
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row]{
            cell.textLabel?.text = category.name
            
            guard let categoryColour = UIColor(hexString: category.bgColor) else {
                fatalError()
            }
            
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: K.toItemSegue, sender: self)
    }
    
    //MARK: - Segue Prepare Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
}
