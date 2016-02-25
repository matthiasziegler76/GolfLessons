//
//  MainTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 24.02.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {

    
    var fetchedResultsController:NSFetchedResultsController?
    var operationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addLesson")
        navigationItem.rightBarButtonItem = addButton
        
        let operation = LoadModelOperation { context in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let request = NSFetchRequest(entityName: "Customer")
                let pred = NSPredicate(value: true)
                request.predicate = pred
                let nameSort = NSSortDescriptor(key: "firstName", ascending: true)
                //let dateSort = NSSortDescriptor(key: "", ascending: false)
                request.sortDescriptors = [nameSort]
                request.fetchLimit = 20
                
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
            
        return section?.numberOfObjects ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        self.configureCell(cell, indexPath: indexPath)
        
        
        return cell
    }
    
    func configureCell(cell:UITableViewCell, indexPath:NSIndexPath){
        
        let customer = fetchedResultsController?.objectAtIndexPath(indexPath) as! Customer
        cell.textLabel?.text = customer.firstName
    }
    
    
    // MARK: - TableView delegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            
            guard let objToDelete = self.fetchedResultsController?.objectAtIndexPath(indexPath) else{return}
            
            fetchedResultsController?.managedObjectContext.deleteObject(objToDelete as! Customer)
        }
    }
    
    // MARK: Add lesson
    
    func addLesson(){
        
        guard let context = fetchedResultsController?.managedObjectContext else{return}
        
        let customer = NSEntityDescription.insertNewObjectForEntityForName("Customer", inManagedObjectContext: context) as! Customer
            customer.firstName = "Brigi"
        
        
        do{
            try context.save()
        }catch{
            print("error saving")
        }
        
    }
}



extension MainTableViewController : NSFetchedResultsControllerDelegate{
    
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
