//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    var selectedCategory: Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colourHex = selectedCategory?.bgColor{
            
            title = selectedCategory?.name
            
            guard let nevBar = self.navigationController?.navigationBar else{ fatalError("Navigation controller deos not exist.")}
            
            nevBar.barTintColor = UIColor(hexString: colourHex)
        }
    }
    
    //MARK: - Tableview Datasource Metods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No items added yet"
        }
        
        if let colour = UIColor(hexString: selectedCategory!.bgColor)?.darken(byPercentage: CGFloat(Float(indexPath.row) / Float(todoItems!.count))){
            
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
            item.done ? (tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark) : (tableView.cellForRow(at: indexPath)?.accessoryType = .none)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFiled = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if textFiled.text != ""{
                
                if let currentCategory = self.selectedCategory{
                    do {
                        try self.realm.write{
                            let newItem = Item()
                            newItem.title = textFiled.text!
                            newItem.dateCreated = Date()
                            newItem.bgColor = UIColor.randomFlat().hexValue()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving new items, \(error)")
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
            alert.removeFromParent()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textFiled = alertTextField
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            do {
                try realm.write{
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Error while deleting todoitem, \(error)")
            }
        }
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
