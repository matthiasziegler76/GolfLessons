//
//  TypeTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 13.06.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData


protocol TypeTableviewControllerDelegate {
    
    func controllerDidSelectType(controller:TypeTableViewController, lessonType:LessonType)
    
}

class TypeTableViewController: UITableViewController {

    var delegate:TypeTableviewControllerDelegate?
    
    var fetchedResultsController:NSFetchedResultsController?
    var operationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let addTypeBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addType))
        
        self.navigationItem.rightBarButtonItem = addTypeBarButton
        
        let operation = LoadModelOperation { context in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let request = NSFetchRequest(entityName: "LessonType")
                let pred = NSPredicate(value: true)
                request.predicate = pred
                let nameSort = NSSortDescriptor(key: "type", ascending: true)
        
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
    
    func addType(){
       
        self.performSegueWithIdentifier("AddType", sender: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath)
        
        self.configureCell(cell, indexPath: indexPath)
        
        
        return cell
    }
    
    func configureCell(cell:UITableViewCell, indexPath:NSIndexPath){
        
        guard let lessonType = fetchedResultsController?.objectAtIndexPath(indexPath) as? LessonType  else{return}
        
        cell.textLabel?.text = lessonType.type
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        // Give lessontype back
        
        let selectedLessonType = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! LessonType
        self.delegate?.controllerDidSelectType(self, lessonType: selectedLessonType)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete{
           
            let objectToDelete = self.fetchedResultsController?.objectAtIndexPath(indexPath)
            self.fetchedResultsController?.managedObjectContext.deleteObject(objectToDelete as! LessonType)
            
            do{
                try self.fetchedResultsController?.managedObjectContext.save()
            }catch{
               print("Error saving")
            }
            
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AddType"{
        
            let destination = segue.destinationViewController as! AddEditTypeTableViewController
            destination.delegate = self
            
            let child = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            child.parentContext = self.fetchedResultsController?.managedObjectContext
            destination.context = child
        }
    }
}

extension TypeTableViewController : NSFetchedResultsControllerDelegate{
    
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

extension TypeTableViewController : AddEditTypeTableViewControllerDelegate{
    
    func controllerDidCancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func controllerDidAddType(controller: AddEditTypeTableViewController, type: LessonType) {
        
        controller.context!.performBlock({
            
            if controller.context!.hasChanges{
                do{
                    try controller.context!.save()
                }catch{
                    let error  = error as NSError
                    print("Error saving child context \(error.localizedDescription)")
                }
                
            }
            
            do{
                try self.fetchedResultsController?.managedObjectContext.save()
            }catch{
                print("Save error")
            }
            
        })
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func controllerDidFinshEditingType(controller: AddEditTypeTableViewController, type: LessonType) {
    }
    
}

