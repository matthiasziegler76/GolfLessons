//
//  AddEditKursTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 05.04.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

protocol AddKursControllerDelegate{
    
    func addKursControllerDidSave(controller: AddEditKursTableViewController, didSave:Bool)
    
}

class AddEditKursTableViewController: UITableViewController {

    var delegate:AddKursControllerDelegate?
    var managedObjectContext:NSManagedObjectContext!
    
    var dateFormatter:NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EE. dd MMMM yyyy HH:mm"
        
        return formatter
    }
    var datePickerVisible = false
    
    var saveButton:UIBarButtonItem!
    var titleLabel:UILabel?
    var date:NSDate?
    var theme:String?
    var kursToEdit:Kurs?
    var kursToAdd:Kurs?
    var customers = [Customer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let kurs = self.kursToEdit{
            
            if let date = kurs.date{
                print("Kurs: \(date)")
            }
            theme = kurs.theme ?? ""
            self.customers = kursToEdit?.customers?.allObjects as! [Customer]
            print("Customers \(customers)")
        }else{
            
            kursToAdd = NSEntityDescription.insertNewObjectForEntityForName("Kurs", inManagedObjectContext: self.managedObjectContext) as? Kurs
            theme = "Neuer Kurs"
            kursToAdd?.theme = theme
            kursToAdd?.date = NSDate()
        }
        
        self.saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save))
        self.saveButton.enabled = true
        self.navigationItem.rightBarButtonItem = self.saveButton
        
        
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(AddEditKursTableViewController.cancel))
        self.navigationItem.leftBarButtonItem = cancelItem
    }
    

    
    func addCustomer(){
        
        let controller = storyboard?.instantiateViewControllerWithIdentifier("CustomersTableViewController") as! CustomersTableViewController
        controller.delegate = self
        
        let navigationController = UINavigationController(rootViewController: controller)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    func save(){
        
        let themeCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! CustomCell
        
        if let kurs = self.kursToEdit{
            
            kurs.theme = themeCell.textField.text
            
        }else{
            
            kursToAdd!.theme = themeCell.textField.text
            
        }
        
        self.delegate?.addKursControllerDidSave(self, didSave: true)
    }

    
    func cancel() {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            
        case 0:
            return self.datePickerVisible ? 3 : 2
            
        case 1:
            
            var count = 0
            count = kursToEdit?.customers?.allObjects.count ?? 0
            return   count
        
        case 2:
            return 1
            
        default:
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        if indexPath.section == 0{
            
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomCell
                
                var theme = ""
                
                if let kurs = self.kursToEdit{
                    theme = kurs.theme!
                }else{
                    theme = kursToAdd!.theme!
                }
                (cell as! CustomCell).textField?.placeholder = "Kurs"
                (cell as! CustomCell).textField?.text = theme
                (cell as! CustomCell).textField?.delegate = self
                
            }
            if indexPath.row == 1{
                let date = kursToEdit?.date ?? NSDate()
                cell.textLabel?.text = dateFormatter.stringFromDate(date)
            }
            
        }
        if indexPath.section == 1{

            let customer = self.customers[indexPath.row]
            print("Customer \(customer)")
            let name = customer.firstName ?? ""
            let lastName = customer.lastName ?? ""
            cell.textLabel?.text = name + " " + lastName

        }
        
        if indexPath.section == 2{
            
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.text = "Add customer"
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 0{
            
            if indexPath.row == 1{
                
                // Show date picker
                self.tableView.beginUpdates()
                self.datePickerVisible = !self.datePickerVisible
                
                if self.datePickerVisible {
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow:2, inSection: 0)], withRowAnimation: .Top)
                    
                }else{
                    self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow:2, inSection: 0)], withRowAnimation: .Top)
                }
                
                self.tableView.endUpdates()
            }
            
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow:2, inSection: 0)){
                let datePicker = UIDatePicker()
                datePicker.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(datePicker)
                datePicker.topAnchor.constraintEqualToAnchor(cell.topAnchor).active = true
                datePicker.bottomAnchor.constraintEqualToAnchor(cell.bottomAnchor).active = true
                datePicker.leftAnchor.constraintEqualToAnchor(cell.leftAnchor).active = true
                datePicker.rightAnchor.constraintEqualToAnchor(cell.rightAnchor).active = true
                
                datePicker.addTarget(self, action: #selector(datePickerValueChanged), forControlEvents: .ValueChanged)
            }
            
            
        }
        
        if indexPath.section == 2{
            self.addCustomer()
        }
        
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height:CGFloat = 0.0
        
        switch indexPath.section {
            
        case 0:
            
            switch indexPath.row {
            case 0:
                height = UITableViewAutomaticDimension
                
            case 1:
                height = UITableViewAutomaticDimension
                
            case 2:
                height = self.datePickerVisible ? 216 : 0
                
            default:
                height = UITableViewAutomaticDimension
            }
            
        case 1:
            
            height = UITableViewAutomaticDimension
            
        default:
            height = UITableViewAutomaticDimension
        }
        return height
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        
        case 0:
            return false
        
        case 1: return true
        
        default:
            return false
        }
    }
    

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        case 1:
            return true
        default:
            return false
        }
    }
    
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if indexPath.section == 1{
            return .Delete
        }
        
        return .None
    
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1{
            if editingStyle == .Delete {
                
                tableView.beginUpdates()
                let customer = self.customers[indexPath.row]
                let set = NSMutableSet(set:(kursToEdit?.customers)!)
                set.removeObject(customer)
                
                kursToEdit?.customers = set.copy() as? NSSet
                
                do{
                    try self.managedObjectContext.save()
                }catch{
                    print("Error saving")
                }
                
                self.customers.removeAtIndex(indexPath.row)
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.endUpdates()
                
            }
        }
    }
    
    
    @IBAction func datePickerValueChanged(sender:UIDatePicker){
    
        self.date = sender.date
        self.kursToEdit?.date = self.date
        
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        self.tableView .reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        print("Date: \(self.date)")
    }
    
    
    

}


extension AddEditKursTableViewController : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        self.theme = textField.text!
    }
}


extension AddEditKursTableViewController : CustomerPickerViewControllerDelegate{
   
    func customerPickerDidCancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func customerPickerDidPick(controller: CustomersTableViewController, customer: Customer) {

        let customerToAdd = self.managedObjectContext.objectWithID(customer.objectID) as! Customer

        if let customersSet = self.kursToEdit?.mutableSetValueForKey("customers"){
        
            customersSet.addObject(customerToAdd)
        }
        
        self.customers = kursToEdit?.customers?.allObjects as! [Customer]
        
        self.dismissViewControllerAnimated(true, completion: nil)
        self.tableView.reloadData()
    }
    
}


