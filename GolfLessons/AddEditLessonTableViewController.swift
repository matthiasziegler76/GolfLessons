//
//  AddEditLessonTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 25.02.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

protocol AddEditLessonViewControllerDelegate{
    
    func controllerDidCancel(controller:AddEditLessonTableViewController)
    func controllerDidFinishEditing(controller:AddEditLessonTableViewController, lesson:Lesson)
    func controllerDidAdd(controller:AddEditLessonTableViewController, lesson:Lesson)
}

class AddEditLessonTableViewController: UITableViewController {

    var managedObjectContext:NSManagedObjectContext?
    var lessonToEdit:Lesson?
    var lessonType:LessonType?
    var delegate:AddEditLessonViewControllerDelegate?
    
    var customer:Customer?
    var price:NSNumber?
    var duration:NSNumber?
    
    var date:NSDate?
    var payed:Bool?
    var amount:NSNumber?

    
    var customers = [Customer]()
    var filteredCustomers = [Customer]()
    var showSearchResults = false
    
    
    var dateFormatter:NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EE. dd MMMM yyyy HH:mm"
        
        return formatter
    }
    
    
    @IBOutlet weak var customerLabel:UILabel!
    @IBOutlet weak var customerSearchBar:UISearchBar!
    @IBOutlet weak var customerPicker:UIPickerView!
    var customerPickerVisible = false
    
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var datePicker:UIDatePicker!
    var datePickerVisible = false
    
    @IBOutlet weak var priceLabel:UILabel!
    @IBOutlet weak var pricePicker:UIPickerView!
    var pricePickerVisible = false
    var priceValues:[Int]!
    
    @IBOutlet weak var payedLabel:UILabel!
    @IBOutlet weak var payedSwitche:UISwitch!
    
    @IBOutlet weak var durationSegmentControl: UISegmentedControl!
    @IBOutlet weak var lessonTypeSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var lessonTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(AddEditLessonTableViewController.cancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(AddEditLessonTableViewController.save))
        navigationItem.rightBarButtonItem = saveButton
        
        priceValues = [Int]()
        
        for i in 0..<85{
            
             if ((i % 5) == 0){
               priceValues.append(i)
            }
        }
        
        payedSwitche.selected = false
        payed = false
        datePicker.minuteInterval = 5
        datePicker.locale = NSLocale.currentLocale()
    
        
        
        customerPicker.delegate = self
        customerPicker.dataSource = self
        
        pricePicker.delegate = self
        pricePicker.dataSource = self
        
        pricePicker.reloadAllComponents()
        pricePicker.selectRow(priceValues.count - 3, inComponent: 0, animated: false)
        
        customerSearchBar.barTintColor = UIColor.whiteColor()
        customerSearchBar.placeholder = "Suchen..."
        customerSearchBar.delegate = self
        self.fetchCustomers()
        
        guard let lesson = lessonToEdit else{return}
        self.setUpUIWithLesson(lesson)
    }
    
    func fetchCustomers(){
        
        let fetchRequest = NSFetchRequest(entityName: "Customer")
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "firstName", ascending: true)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sort]
        
        do{
            customers = try managedObjectContext?.executeFetchRequest(fetchRequest) as! [Customer]
        }catch{
           print("Error \(error)")
        }
        
        customerPicker.reloadAllComponents()
    }
    
    
    func setUpUIWithLesson(lesson:Lesson){
        
        if let customer = lesson.customer {
            
            let firstName = customer.firstName ?? "No firstname"
            let lastName = customer.lastName ?? "No lastname"
            customerLabel.text = firstName + " " + lastName
        }
        
        if let price = lesson.amount{
            priceLabel.text = String(price) + ",00" + " €"
            let index = priceValues.indexOf(Int(price)) ?? 0
            pricePicker.selectRow(index, inComponent: 0, animated: false)
            self.price = priceValues[index]
            
            print("Price \(self.price)")
        }
        
        if let duration = lesson.duration{
            
            self.duration = duration
            switch duration{
                
            case 25: durationSegmentControl.selectedSegmentIndex = 0
            case 50: durationSegmentControl.selectedSegmentIndex = 1
            case 75: durationSegmentControl.selectedSegmentIndex = 2
            case 30: durationSegmentControl.selectedSegmentIndex = 3
            case 60: durationSegmentControl.selectedSegmentIndex = 4
            case 90: durationSegmentControl.selectedSegmentIndex = 5
            default: durationSegmentControl.selected = false
            }
        }
        
        if let date = lessonToEdit?.date{
            datePicker.date = date
            dateLabel.text = dateFormatter.stringFromDate(date) + " Uhr"
            self.date = date
        }
        
        if let payed = lesson.payed?.boolValue{
            payedSwitche.setOn(payed, animated: false)
            self.payed = payed
        }else{
            payedSwitche.setOn(false, animated: false)
            payedLabel.text?.appendContentsOf("?")
            self.payed = false
        }
        
        if lesson.lessonType != nil{
            self.lessonType = lesson.lessonType
            self.lessonTypeLabel.text = self.lessonType?.type
        }
    }

    func save(){
        
        guard   let date = self.date,
                let price = self.price,
                let duration = self.duration,
                let payed = self.payed else{print("something missing"); return}
        
        if lessonToEdit != nil
        {
            
            if let customer = lessonToEdit?.customer
            {
            lessonToEdit?.customer = customer
            lessonToEdit?.date = date
            lessonToEdit?.payed = payed
            lessonToEdit?.amount = price
            lessonToEdit?.duration = duration
                
                if let lessonType = self.lessonType
                {
                    lessonToEdit?.lessonType = lessonType
                }
                
            self.delegate?.controllerDidFinishEditing(self, lesson: lessonToEdit!)
            }
            
        }else{
            if let context = self.managedObjectContext,
            let customer = self.customer
            {
                let lessonToAdd = NSEntityDescription.insertNewObjectForEntityForName("Lesson", inManagedObjectContext: context) as! Lesson
                lessonToAdd.date = date
                lessonToAdd.customer = customer
                lessonToAdd.payed = payed
                lessonToAdd.amount = price
                lessonToAdd.duration = duration
                
                if let lessonType = self.lessonType
                {
                    lessonToAdd.lessonType = lessonType
                }
                self.delegate?.controllerDidAdd(self, lesson: lessonToAdd)
            }
        }
    }
    
    func cancel(){
       self.delegate?.controllerDidCancel(self)
    }
    
    
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = UITableViewAutomaticDimension
        
        if indexPath.section == 0{
            
            switch indexPath.row{
                
            case 0: height = UITableViewAutomaticDimension
            case 1: height = customerPickerVisible ? UITableViewAutomaticDimension : 0
            case 2: height = UITableViewAutomaticDimension
            case 3: height = datePickerVisible ? UITableViewAutomaticDimension : 0
            case 4: height = UITableViewAutomaticDimension
            case 5: height = pricePickerVisible ? UITableViewAutomaticDimension : 0
                
            default: height = UITableViewAutomaticDimension
            }

        }
        
        if indexPath.section == 1{
            
            height = UITableViewAutomaticDimension
        
            
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        tableView.beginUpdates()
        
        switch indexPath.row{
            
        case 0: let controller = storyboard?.instantiateViewControllerWithIdentifier("CustomersTableViewController")  as! CustomersTableViewController
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
            
            
        case 2: datePickerVisible = !datePickerVisible
                datePicker.hidden = !datePickerVisible
                if datePickerVisible{
                    customerPickerVisible = false
                    customerPicker.hidden = true
                    //customerSearchBar.endEditing(true)
                    customerSearchBar.resignFirstResponder()
                    pricePickerVisible = false
                    pricePicker.hidden = true
                    
                }
                self.updateLabelColor()
        
        case 4: pricePickerVisible = !pricePickerVisible
                pricePicker.hidden = !pricePickerVisible
                if pricePickerVisible{
                    customerPickerVisible = false
                    customerPicker.hidden = true
                    //customerSearchBar.endEditing(true)
                    customerSearchBar.resignFirstResponder()
                    datePickerVisible = false
                    datePicker.hidden = true
                }
        
                self.updateLabelColor()
            
        default: print("Not assigned!")
        }
        
        tableView.endUpdates()
    }
    
    
    func updateLabelColor(){
        customerLabel.textColor = customerPickerVisible ? UIColor.orangeColor() : UIColor.blackColor()
        dateLabel.textColor = datePickerVisible ? UIColor.orangeColor() : UIColor.blackColor()
        priceLabel.textColor = pricePickerVisible ? UIColor.orangeColor() : UIColor.blackColor()
    }
    
    
    @IBAction func datePickerChanged(sender: AnyObject) {
        
        let datePicker = sender as! UIDatePicker
        dateLabel.text = dateFormatter.stringFromDate(datePicker.date)
        self.date = datePicker.date
    }
    
    
    
    @IBAction func durationSegmentControlValueChanged(sender: AnyObject) {
        
        let segment = sender as! UISegmentedControl
        
        switch segment.selectedSegmentIndex{
            
            case 0: self.duration = 25.00
            case 1: self.duration = 50.00
            case 2: self.duration = 75.00
            case 3: self.duration = 60.00
            case 5: self.duration = 90.00
            case 5: self.duration = 120.00
            default: self.duration = nil
        }
    }
    
    
    @IBAction func payedSwitchAction(sender: AnyObject) {
        
       let payedSwitch = sender as! UISwitch
        self.payed = payedSwitch.on
    }
    
    
    @IBAction func chooseType(sender: AnyObject){
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TypeTableViewController") as! TypeTableViewController
        controller.delegate = self

        self.navigationController?.pushViewController(controller, animated: true)
    }
}


extension AddEditLessonTableViewController : UIPickerViewDataSource{
   
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
       
        let comps = 2
        return comps
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        var rows = 0
        
        if pickerView == pricePicker{
            
            switch component{
                
            case 0: guard let priceValues = priceValues else{return rows}
                    rows = priceValues.count
            case 1: rows = 1
            default: rows = 0
            }
            
            
        }
        
        return rows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var title = ""
        
        if pickerView == pricePicker{
            
            switch component{
                
            case 0: guard let priceValues = priceValues else{return title}
            title = "\(priceValues[row])"
            case 1: title = "00 €"
            default: title = ""
            }
            
        }
        
        return title
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let font = UIFont(name: "Avenir", size: 17)
        let attributes:[String:AnyObject] = [NSFontAttributeName: font!]
        
        var title = NSMutableAttributedString(string: "", attributes: attributes)
        
        
        if pickerView == pricePicker{
            
            switch component{
                
            case 0: guard let priceValues = priceValues else{return title}
            title = NSMutableAttributedString(string:"\(priceValues[row])")
            case 1: title = NSMutableAttributedString(string:"00 €")
            default: title = NSMutableAttributedString(string:"")
            }
            
        }
        
        return title
        
    }

    
}


extension AddEditLessonTableViewController : UIPickerViewDelegate{
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            self.price = priceValues[row]
            priceLabel.text = String(price!) + ",00 €"
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        switch component{
            
        case 0: return 60.0
        case 1: return 60.0
        default: return 0.0
        }
    }
    
    
}


extension AddEditLessonTableViewController : UISearchBarDelegate{
   
    func searchBarTextDidBeginEditing(searchBar: UISearchBar){
        
        showSearchResults = true
        customerPicker.reloadAllComponents()
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        
        showSearchResults = true
        filteredCustomers = customers.filter({ (customer) -> Bool in
            let lastNameText: NSString = customer.firstName!
            
            return (lastNameText.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        customerPicker.reloadAllComponents()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        showSearchResults = false
        searchBar.text = nil
        customerPicker.reloadAllComponents()

    }
}

extension AddEditLessonTableViewController : CustomerPickerViewControllerDelegate{
    
    func customerPickerDidCancel() {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func customerPickerDidPick(controller: CustomersTableViewController, customer: Customer) {
        
        if let lessonToEdit = lessonToEdit{
            
            let fromId = customer.objectID
            let toId = self.managedObjectContext?.objectWithID(fromId) as! Customer
            lessonToEdit.customer = toId
        
        
            do{
                try self.managedObjectContext?.save()
                self.setUpUIWithLesson(lessonToEdit)
            }catch{
                print("Error")
            }
            
        }else{
           
            let fromId = customer.objectID
            let toId = self.managedObjectContext?.objectWithID(fromId) as! Customer
            self.customer = toId
            
            
            do{
                try self.managedObjectContext?.save()
                guard let customer = self.customer else{return}
                self.customerLabel.text = customer.firstName! + " " + customer.lastName!
            }catch{
                print("Error")
            }
        }
    
        self.navigationController?.popViewControllerAnimated(true)
    }
}


extension AddEditLessonTableViewController : TypeTableviewControllerDelegate{
    
    func controllerDidSelectType(controller: TypeTableViewController, lessonType: LessonType) {
        
        let lessonTypeID = lessonType.objectID
        
        self.lessonType = self.managedObjectContext!.objectWithID(lessonTypeID) as? LessonType
        
        self.lessonTypeLabel.text = lessonType.type
        self.navigationController?.popViewControllerAnimated(true)
        
    }
}


