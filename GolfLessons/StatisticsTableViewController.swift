//
//  StatisticsTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 21.03.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData
import MessageUI


class StatisticsTableViewController: UITableViewController {

    var managedObjectContext:NSManagedObjectContext?
    
    var month:NSInteger?
    var year:NSInteger?
    
    var fetchedResultsController:NSFetchedResultsController?
    var operationQueue = OperationQueue()
    
    var dateFormatter:NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EE. dd MMMM yyyy HH:mm"
        
        return formatter
    }
    
    var csvData:NSData?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let options = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(StatisticsTableViewController.chooseOption))
        
        navigationItem.rightBarButtonItems = [options]
        
        let operation = LoadModelOperation { context in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.managedObjectContext = context
                
                let request = NSFetchRequest(entityName: "Lesson")
                
                let pred = NSPredicate(value: true)
                
                request.predicate = pred
                let nameSort = NSSortDescriptor(key: "date", ascending: true)
    
                request.sortDescriptors = [nameSort]
                request.fetchLimit = 20
                
                let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
                
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
    
    func chooseOption(){
        
        let actionsheet = UIAlertController(title: "Wählen", message: nil, preferredStyle: .ActionSheet)
        actionsheet.addAction(UIAlertAction(title: "Filtern", style: .Default, handler: {
            action in
            self.performSegueWithIdentifier("OptionSegue", sender: self)
        }))
        /*
        actionsheet.addAction(UIAlertAction(title: "Export", style: .Default, handler: {
            action in
            // Print
            self.exportFile()
        }))
        */
        actionsheet.addAction(UIAlertAction(title: "Per Email senden", style: .Default, handler: {
            action in
            self.exportFile()
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionsheet, animated: true, completion: nil)
        
        
        
        
        
    }
    
    
    func updateFetchedResultsController(predicate:NSCompoundPredicate){
        
        self.fetchedResultsController = nil
        
        let request = NSFetchRequest(entityName: "Lesson")
        request.predicate = predicate
        
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [dateSort]
        
        request.fetchLimit = 20
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        self.fetchedResultsController = controller
        self.fetchedResultsController?.delegate = self
        
        do{
            try self.fetchedResultsController?.performFetch()
            self.tableView.reloadData()
        }catch{
           print("Error fetching")
        }


    }

    func exportFile(){
        
        let result = self.fetchedResultsController?.fetchedObjects as! [Lesson]
        
        let exportOperation = ExportOperation(results: result)
        exportOperation.delegate = self
        
        operationQueue.addOperation(exportOperation)
    }
    
    func sendMail(){
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["matthias.ziegler@pga-pros.de"])
        mailComposer.setSubject("Stundenabrechnung")
        mailComposer.setMessageBody("Abrechnung", isHTML: false)
        
        if self.csvData != nil {
           mailComposer.addAttachmentData(self.csvData!, mimeType: "file/csv", fileName: "Abrechnung.csv")
        }
        
        self.presentViewController(mailComposer, animated: true, completion: nil)
        
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StatsCell", forIndexPath: indexPath)
        
        self.configureCell(cell, indexPath: indexPath)
        
        
        return cell
    }
    
    
    func configureCell(cell:UITableViewCell, indexPath:NSIndexPath){
        
        guard let lesson = fetchedResultsController?.objectAtIndexPath(indexPath) as? Lesson where lesson.date != nil else{return}
        
        cell.textLabel?.text = dateFormatter.stringFromDate(lesson.date!) + " Uhr"
        
        if let customer = lesson.customer{
            let lastName = customer.lastName ?? ""
            let firstName = customer.firstName ?? ""
            
            cell.detailTextLabel?.text = firstName + " " + lastName
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "OptionSegue"{
         
            let destination = segue.destinationViewController as! OptionsTableViewController
            destination.delegate = self
        }
    }

}


extension StatisticsTableViewController : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Update:
            
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
            
        case .Insert:
            
            if indexPath != newIndexPath {
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


extension StatisticsTableViewController : OptionsTableViewControllerDelegate{
    
    func optionsTableViewControllerDidCancel() {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func optionsTableViewControllerDidSetPredicate(predicate:NSCompoundPredicate) {
        
        self.updateFetchedResultsController(predicate)
        navigationController?.popViewControllerAnimated(true)
    }
}


extension StatisticsTableViewController :ExportOperationDelegate{
    
    func exportOperationDidFinishExporting(filePath: String) {
        
        self.csvData = NSData(contentsOfFile: filePath)
        print("File path: \(filePath)")
        self.sendMail()
    }
}


extension StatisticsTableViewController : MFMailComposeViewControllerDelegate{
    
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
