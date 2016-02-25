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
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            
            guard let objToDelete = self.fetchedResultsController?.objectAtIndexPath(indexPath) else{return}
            
            fetchedResultsController?.managedObjectContext.deleteObject(objToDelete as! Customer)
        }
    }
    
    func addLesson(){
        
        guard let context = fetchedResultsController?.managedObjectContext else{return}
        
        print("Context we have")
        
        
        
        let customer = NSEntityDescription.insertNewObjectForEntityForName("Customer", inManagedObjectContext: context) as! Customer
        customer.firstName = "Brigi"
        
        
        do{
            try context.save()
        }catch{
            print("error saving")
        }
        
//        do{
//            try fetchedResultsController?.performFetch()
//        }catch{
//            print("error fetching")
//        }
        
//        let request = NSFetchRequest(entityName: "Customer")
//        let pred = NSPredicate(value: true)
//        let nameSort = NSSortDescriptor(key: "firstName", ascending: true)
//        //let dateSort = NSSortDescriptor(key: "", ascending: false)
//        request.sortDescriptors = [nameSort]
//        request.predicate = pred
//        request.fetchLimit = 20
//
//        do{
//                let res = try context.executeFetchRequest(request)
//            print((res.first as! Customer).firstName)
//                }catch{
//                      print("error fetching")
//        }
        
        
        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainTableViewController : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        //guard let indexPath = indexPath else{return}
        
        switch type{
        case .Update:
            //tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
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
