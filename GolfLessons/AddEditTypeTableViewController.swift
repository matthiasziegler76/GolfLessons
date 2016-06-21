//
//  AddEditTypeTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 13.06.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

protocol AddEditTypeTableViewControllerDelegate {
    
    func controllerDidAddType(controller:AddEditTypeTableViewController, type:LessonType)
    func controllerDidFinshEditingType(controller:AddEditTypeTableViewController, type:LessonType)
    func controllerDidCancel()
}

class AddEditTypeTableViewController: UITableViewController {

    var context:NSManagedObjectContext?
    var delegate:AddEditTypeTableViewControllerDelegate?
    var typeToEdit:LessonType?
    var editingChanged = false
    
    
    @IBOutlet weak var addTypeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save))
         self.navigationItem.rightBarButtonItem = saveButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editingDidBegin(sender: AnyObject) {
        print("Editing did begin")
    }
    
    @IBAction func textFieldEditingChanged(sender: AnyObject) {
        print("Editing changed")
        self.editingChanged = true
    }
    
    @IBAction func editingDidEnd(sender: AnyObject) {
        print("Editing ended")
    }
    
    @IBAction func textFieldEndOnExit(sender: AnyObject) {
        print("end on exit")
    }

    
    func save(){
        
        guard let context = self.context else{return}
        
        if let lessonType = self.typeToEdit{
            if self.editingChanged{
                
                if let text = self.addTypeTextField.text where text.characters.count > 0{
                    
                    print("Saving")
                    lessonType.type = self.addTypeTextField.text
                    
                    do{
                        try self.context?.save()
                    }catch{
                        print("Error saving")
                    }
                    
                    self.delegate?.controllerDidFinshEditingType(self, type: lessonType)
                }
            }
            
        }else{
            
            if let text = self.addTypeTextField.text where text.characters.count > 0{
               
                let newLessonType = NSEntityDescription.insertNewObjectForEntityForName("LessonType", inManagedObjectContext: context) as! LessonType
                
                newLessonType.type = self.addTypeTextField.text

                do{
                    try self.context?.save()
                }catch{
                    print("Error saving")
                }
                
                
                self.delegate?.controllerDidAddType(self, type: newLessonType)
                
            }
        }
        
    }
    
}
