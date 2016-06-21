//
//  AddEditCustomerTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 26.02.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

protocol AddEditCustomerTableViewControllerDelegate{
    
    func controllerDidCancel()
    func controllerDidFinishEditing(controller: AddEditCustomerTableViewController, customer:Customer)
    func controllerDidAddCustomer(controller: AddEditCustomerTableViewController, customer:Customer)
}

class AddEditCustomerTableViewController: UITableViewController {

    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var managedObjectContext:NSManagedObjectContext?
    var delegate:AddEditCustomerTableViewControllerDelegate?
    var customerToEdit:Customer?
    
    var cancelButton:UIBarButtonItem!
    var editButton:UIBarButtonItem!
    var saveButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(AddEditCustomerTableViewController.cancel))
        self.saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(AddEditCustomerTableViewController.save))
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        if customerToEdit != nil{
            self.setEditing(true, animated: false)
            firstNameTextField.text = customerToEdit?.firstName
            lastNameTextField.text = customerToEdit?.lastName
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        self.navigationItem.rightBarButtonItem = editing ? self.saveButton : self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cancel(){
        
        self.delegate?.controllerDidCancel()
    }
    
    func save(){
        
        if let firstName = firstNameTextField.text where firstName.characters.count > 0,
            let lastName = lastNameTextField.text where lastName.characters.count > 0 {
        
            guard let customerToEdit = customerToEdit else{
                
                let customerToAdd = NSEntityDescription.insertNewObjectForEntityForName("Customer", inManagedObjectContext:self.managedObjectContext!) as! Customer
                    customerToAdd.firstName = firstName
                    customerToAdd.lastName = lastName
                
                    self.delegate?.controllerDidAddCustomer(self, customer: customerToAdd)
                
                return
                }
                
                    customerToEdit.firstName = firstNameTextField.text
                    customerToEdit.lastName = lastNameTextField.text
            
            self.delegate?.controllerDidFinishEditing(self,customer: customerToEdit)
        
        }else{
            
            self.showTextFieldEmptyAlert()
        }
    }
    
    
    func showTextFieldEmptyAlert(){
     
        let alert = UIAlertController(title: "Achtung", message: "Bitte gib einen Vor- und Nachnamen ein!", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

extension AddEditCustomerTableViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.setEditing(true, animated: false)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField.text?.characters.count == 0{
            
            self.setEditing(false, animated: false)
        }
    }
}
