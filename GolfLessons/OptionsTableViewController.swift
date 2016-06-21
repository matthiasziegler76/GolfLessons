//
//  OptionsTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 21.03.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

protocol OptionsTableViewControllerDelegate{
    
    func optionsTableViewControllerDidCancel()
    func optionsTableViewControllerDidSetPredicate(predicate:NSCompoundPredicate)
}


class OptionsTableViewController: UITableViewController {

    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var selectTypeButton: UIButton!
    @IBOutlet weak var lessonTypeLabel: UILabel!
        
    var delegate:OptionsTableViewControllerDelegate?
    var lessonType:LessonType?
    
    var typePredicate:NSPredicate?
    
    var startPickerVisible = false
    var endPickerVisible = false
    
    var dateFormatter:NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EE. dd MMMM yyyy HH:mm"
        
        return formatter
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Stats"
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(OptionsTableViewController.cancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(OptionsTableViewController.save))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    
    @IBAction func startPickerValueChanged(sender: AnyObject) {
       
        let picker = sender as! UIDatePicker
        startLabel.text = dateFormatter.stringFromDate(picker.date)
    }
    
    
    @IBAction func endPickerValueChanged(sender: AnyObject) {
        
        let picker = sender as! UIDatePicker
        endLabel.text = dateFormatter.stringFromDate(picker.date)
    }
    
    
    @IBAction func selectLessonType(sender: AnyObject) {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TypeTableViewController") as! TypeTableViewController
        controller.delegate = self
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    func save(){
        
        // Pass predicate instead of managed objects
        
        var compPred = NSCompoundPredicate()
        
        let pred = NSPredicate(format: "(date >= %@) AND (date <= %@) ", startDatePicker.date, endDatePicker.date)
        
        compPred = NSCompoundPredicate(andPredicateWithSubpredicates: [pred])
        
        if let typePredicate = self.typePredicate{
            // If a type was picked there is a type predicate
            compPred = NSCompoundPredicate(andPredicateWithSubpredicates: [pred, typePredicate])
        }else{
            // If no type was picked we pass the date predicate
            // Add default values!!!
            compPred = NSCompoundPredicate(andPredicateWithSubpredicates: [pred])
        }
        
        self.delegate?.optionsTableViewControllerDidSetPredicate(compPred)
    }
    
    
    func cancel(){
        
        self.delegate?.optionsTableViewControllerDidCancel()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        tableView.beginUpdates()
        
        if indexPath.row == 0{
            startPickerVisible = !startPickerVisible
            startDatePicker.hidden = !startPickerVisible
    
        }

        if indexPath.row == 2{
            endPickerVisible = !endPickerVisible
            endDatePicker.hidden = !endPickerVisible
            
        }
    
        tableView.endUpdates()
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height:CGFloat = 0.0
        
        switch indexPath{
            case 0: height = 44
            case 1: height = startPickerVisible ?  216.0 : 0.0
            case 2: height = 44
            case 3: height = endPickerVisible ?  216.0 : 0.0
            default: height = 44
        }

        return height
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = UITableViewAutomaticDimension
        
        if indexPath.section == 0{
            switch indexPath.row{
            case 0: height = UITableViewAutomaticDimension
            case 1: height = startPickerVisible ?  UITableViewAutomaticDimension : 0.0
            case 2: height = UITableViewAutomaticDimension
            case 3: height = endPickerVisible ?  UITableViewAutomaticDimension : 0.0
            default: height = 44
            }

        }
        return height
    }
}



extension OptionsTableViewController : TypeTableviewControllerDelegate{
    
    func controllerDidSelectType(controller: TypeTableViewController, lessonType: LessonType) {
        
        self.lessonTypeLabel.text = lessonType.type
        self.typePredicate = NSPredicate(format: "%K == %@", "lessonType.type", lessonType.type!)
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
}
