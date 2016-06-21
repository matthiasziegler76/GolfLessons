//
//  KurseTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 22.03.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

class KurseTableViewController: UITableViewController {

    var fetchedResultsController:NSFetchedResultsController?
    var operationQueue = OperationQueue()
    
    var dateFormatter:NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EE. dd MMMM yyyy HH:mm"
        
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Kurse"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(KurseTableViewController.addCourse))
        navigationItem.rightBarButtonItem = addButton
        
        let operation = LoadModelOperation { context in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let request = NSFetchRequest(entityName: "Kurs")
                let pred = NSPredicate(value: true)
                request.predicate = pred
                let dateSort = NSSortDescriptor(key: "date", ascending: false)
                request.sortDescriptors = [dateSort]
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
    
    
    func addCourse(){
        
        self.performSegueWithIdentifier("AddEditKursTableViewController", sender: nil)
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("KursCell", forIndexPath: indexPath)
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell:UITableViewCell, indexPath:NSIndexPath){
        
        guard let kurs = fetchedResultsController?.objectAtIndexPath(indexPath) as? Kurs else{return}
        
        let date = kurs.date ?? NSDate()
        let theme = kurs.theme ?? "No theme"
        
        cell.textLabel?.text = theme
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(date) + " Uhr"
        
    }

    
    // MARK: - TableView delegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            
            guard let objToDelete = self.fetchedResultsController?.objectAtIndexPath(indexPath) else{return}
            
            fetchedResultsController?.managedObjectContext.deleteObject(objToDelete as! Kurs)
            
            do{
                try fetchedResultsController?.managedObjectContext.save()
            }catch{
                print("Save error")
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.performSegueWithIdentifier("AddEditKursTableViewController", sender: indexPath)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AddEditKursTableViewController"{
         
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! AddEditKursTableViewController
            
            let childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            childContext.parentContext = self.fetchedResultsController?.managedObjectContext
            destination.managedObjectContext = childContext
            destination.delegate = self
            
            
            if sender is NSIndexPath{
                let indexPath = sender as! NSIndexPath
                let kurs = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! Kurs
                
                let childKurs = childContext.objectWithID(kurs.objectID) as! Kurs
                
                destination.kursToEdit = childKurs
                print("Kurs to edit")
            }else{

                print("No kurs to edit")
            }
            
        }
    }
    

}

extension KurseTableViewController : AddKursControllerDelegate{
    
    func addKursControllerDidSave(controller: AddEditKursTableViewController, didSave: Bool) {
        
        let context = controller.managedObjectContext
        
        context.performBlock ({ ()->Void in
            
            if context.hasChanges{
                print("Context has changes")
                do{
                   try context.save()
                }catch{
                   let saveError = error as NSError
                   print("Error saving child \(saveError)")
                }
            }
            
            do{
                try self.fetchedResultsController?.managedObjectContext.save()
            }catch{
                
                let saveError = error as NSError
                
                print("Error saving: \(saveError.localizedDescription)")
            }
            
        })
        
        
        
        
     self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension KurseTableViewController : NSFetchedResultsControllerDelegate{
    
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





