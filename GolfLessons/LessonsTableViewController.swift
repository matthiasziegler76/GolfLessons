//
//  LessonsTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 26.02.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

class LessonsTableViewController: UITableViewController {
    
    var managedObjectContext:NSManagedObjectContext!

    var fetchedResultsController:NSFetchedResultsController?
    var operationQueue = OperationQueue()
    
    var dateFormatter:NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EE. dd MMMM yyyy HH:mm"
        
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(LessonsTableViewController.addLesson))
        navigationItem.rightBarButtonItem = addButton
        
        let operation = LoadModelOperation { context in
            
            self.managedObjectContext = context
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let request = NSFetchRequest(entityName: "Lesson")
                let pred = NSPredicate(value: true)
                request.predicate = pred
                let nameSort = NSSortDescriptor(key: "date", ascending: true)
                //let dateSort = NSSortDescriptor(key: "", ascending: false)
                request.sortDescriptors = [nameSort]
                request.fetchLimit = 20
                
                let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                
                self.fetchedResultsController = controller
                self.fetchedResultsController?.delegate = self
                
                //self.insertDummyCustomer()
                
                do{
                    try self.fetchedResultsController?.performFetch()
                    self.tableView.reloadData()
                }catch{
                    
                }
            }
        }
        
        operationQueue.addOperation(operation)
        
    }
    
    
    func insertDummyCustomer(){
        
        guard let context = fetchedResultsController?.managedObjectContext else{return}
        
        let customer = NSEntityDescription.insertNewObjectForEntityForName("Customer", inManagedObjectContext: context) as! Customer
        
        customer.firstName = "Brigi"
        customer.lastName = "Ágoston"
        
        do{
            print("Saving")
            try context.save()
        }catch{
            print("Error saving")
        }
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? LessonTableViewCell
        
        self.configureCell(cell!, indexPath: indexPath)
        
        
        return cell!
    }
    
    func configureCell(cell:LessonTableViewCell, indexPath:NSIndexPath){
        
        guard let lesson = fetchedResultsController?.objectAtIndexPath(indexPath) as? Lesson where lesson.date != nil else{return}

        cell.lesson = lesson
    }
    
    
    // MARK: - TableView delegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            
            guard let objToDelete = self.fetchedResultsController?.objectAtIndexPath(indexPath) else{return}
            
            fetchedResultsController?.managedObjectContext.deleteObject(objToDelete as! Lesson)
            
            do{
                try fetchedResultsController?.managedObjectContext.save()
            }catch{
                print("Save error")
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.performSegueWithIdentifier("AddEditLessonTableViewController", sender: indexPath)
    }
    
    // MARK: Add lesson
    
    func addLesson(){
        
            self.performSegueWithIdentifier("AddEditLessonTableViewController", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AddEditLessonTableViewController"{
            
            let navController = segue.destinationViewController as! UINavigationController
            let topController = navController.topViewController as! AddEditLessonTableViewController
            topController.delegate = self

            topController.managedObjectContext = fetchedResultsController?.managedObjectContext
            
            if sender is NSIndexPath{
                topController.lessonToEdit = fetchedResultsController?.objectAtIndexPath(sender as! NSIndexPath) as? Lesson
                            }
        }
    }
}



extension LessonsTableViewController : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)! as! LessonTableViewCell, indexPath: indexPath!)
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

extension LessonsTableViewController : AddEditLessonViewControllerDelegate{
    
    func controllerDidCancel(controller: AddEditLessonTableViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func controllerDidFinishEditing(controller: AddEditLessonTableViewController, lesson: Lesson) {
        
        if ((fetchedResultsController?.managedObjectContext.hasChanges) != nil){
            
            do{
                try fetchedResultsController?.managedObjectContext.save()
            }catch{
                print("Error saving \(error)")
            }
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func controllerDidAdd(controller: AddEditLessonTableViewController, lesson: Lesson) {
        
        if ((fetchedResultsController?.managedObjectContext.hasChanges) != nil){
            
            do{
                try fetchedResultsController?.managedObjectContext.save()
            }catch{
                print("Error saving \(error)")
            }
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
