//
//  CustomersTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 26.02.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

protocol CustomerPickerViewControllerDelegate{
    
    func customerPickerDidCancel()
    func customerPickerDidPick(controller:CustomersTableViewController, customer:Customer)
}

class CustomersTableViewController: UITableViewController {
    
    var delegate: CustomerPickerViewControllerDelegate?
    
    var fetchedResultsController:NSFetchedResultsController?
    var operationQueue = OperationQueue()
    
    var searching = false
    var filteredCustomers = [Customer]()
    
    var dateFormatter:NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EE. dd MMMM yyyy HH:mm:ss"
        
        return formatter
    }
    
    var searchController:UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.delegate != nil{
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(CustomersTableViewController.cancel))
            navigationItem.leftBarButtonItem = cancelButton
        }
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(CustomersTableViewController.addCustomer))
        navigationItem.rightBarButtonItem = addButton
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.tableView.tableHeaderView = searchController.searchBar
        
        
        
        let operation = LoadModelOperation { context in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let request = NSFetchRequest(entityName: "Customer")
                let pred = NSPredicate(value: true)
                request.predicate = pred
                let nameSort = NSSortDescriptor(key: "lastName", ascending: true)
                request.sortDescriptors = [nameSort]
                
                let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                
                self.fetchedResultsController = controller
                self.fetchedResultsController?.delegate = self
                
                do{
                    try self.fetchedResultsController?.performFetch()
                    self.tableView.reloadData()
                }catch{
                    
                }
            }
        }
        
        operationQueue.addOperation(operation)
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]
        
        if searching{
            return filteredCustomers.count
        }else{
            return section?.numberOfObjects ?? 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomerCell", forIndexPath: indexPath)
        
        if searching{
            configureSearchCell(cell, indexPath: indexPath)
        }else{
           self.configureCell(cell, indexPath: indexPath)
        }
        
        
        
        
        return cell
    }
    
    func configureCell(cell:UITableViewCell, indexPath:NSIndexPath){
        
        guard let customer = fetchedResultsController?.objectAtIndexPath(indexPath) as? Customer where customer.lastName != nil && customer.lastName != nil else{return}
        
        cell.textLabel?.text =  customer.lastName! + " " + customer.firstName!
    }
    
    func configureSearchCell(cell:UITableViewCell, indexPath:NSIndexPath){
        
        let customer = filteredCustomers[indexPath.row]
        
        let firstName = customer.firstName ?? ""
        let lastName = customer.lastName ?? ""
        
        cell.textLabel?.text = lastName + " " + firstName
    }

    
    // MARK: - TableView delegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            
            guard let objToDelete = self.fetchedResultsController?.objectAtIndexPath(indexPath) else{return}
            
            fetchedResultsController?.managedObjectContext.deleteObject(objToDelete as! Customer)
            
            do{
                try fetchedResultsController?.managedObjectContext.save()
            }catch{
                print("Save error")
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if self.delegate == nil{
            
            self.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("AddCustomer", sender: indexPath)
            
        }else{
            
            if searching{
                self.dismissViewControllerAnimated(true, completion: nil)
                let pickedCustomer = filteredCustomers[indexPath.row]
                self.delegate?.customerPickerDidPick(self, customer: pickedCustomer)
            }else{
                guard let fetchedResultsController = fetchedResultsController else{return}
                let pickedCustomer = fetchedResultsController.objectAtIndexPath(indexPath) as! Customer
                self.delegate?.customerPickerDidPick(self, customer: pickedCustomer)
            }
            
        }
    }
    
    // MARK: Add lesson
    
    func addCustomer(){
        
        self.performSegueWithIdentifier("AddCustomer", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AddCustomer"{
            
            let navController = segue.destinationViewController as! UINavigationController
            let topController = navController.topViewController as! AddEditCustomerTableViewController
            
            topController.managedObjectContext = fetchedResultsController?.managedObjectContext
            topController.delegate = self
            
            if sender is NSIndexPath{
                topController.customerToEdit = fetchedResultsController?.objectAtIndexPath(sender as! NSIndexPath) as? Customer
            }
        }
    }
    
    func cancel(){
        
        if self.delegate != nil{
            self.delegate?.customerPickerDidCancel()
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}



extension CustomersTableViewController : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
            
        case .Insert: if indexPath != newIndexPath {
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
            
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
            
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type{
            
        case .Move: self.tableView.reloadData()
            
        case .Update: self.tableView.reloadData()
            
        case .Insert: self.tableView.reloadData()
            
        default: print("Invalid")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}


extension CustomersTableViewController : UISearchResultsUpdating{
    
    func updateSearchResultsForSearchController(searchController: UISearchController){
        
        guard let searchText = searchController.searchBar.text else{return}
        
        let searchPredicate = NSPredicate(format: "lastName contains[c] %@", searchText)
        
        if let fetchedObjects = self.fetchedResultsController!.fetchedObjects as? [Customer]{
            
            filteredCustomers = fetchedObjects.filter() {
                return searchPredicate.evaluateWithObject($0)
            }
        }
        
        
        self.tableView.reloadData()
        
    }
    
}

extension CustomersTableViewController : UISearchControllerDelegate, UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        print("searchBarTextDidBeginEditing")
        searching = true
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
        searching = false
        tableView.reloadData()
    }
    
}

extension CustomersTableViewController : AddEditCustomerTableViewControllerDelegate{
    
    func controllerDidCancel() {
        print("Controller did cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func controllerDidFinishEditing(controller: AddEditCustomerTableViewController, customer:Customer) {
        
        do{
            try self.fetchedResultsController?.managedObjectContext.save()
        }catch{
            print("Error saving")
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func controllerDidAddCustomer(controller: AddEditCustomerTableViewController, customer:Customer) {
        
        do{
            try self.fetchedResultsController?.managedObjectContext.save()
        }catch{
            print("Error saving")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
