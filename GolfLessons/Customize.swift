//
//  Customize.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 05.04.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit

protocol CustomizeCellProtocol {

    func customizeWithLabel()
    func customizeWithTextField()
    func customizeWithDatePicker()
    
}


extension CustomizeCellProtocol where Self:UITableViewCell {
    
    func customizeWithLabel(){
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Custom Cell"
        label.sizeToFit()
        self.addSubview(label)
        label.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 16).active = true
        label.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: 8).active = true
        label.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 10).active = true
        label.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -10).active = true
    }
    
    
    func customizeWithTextField(){
        
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Custom TextField Cell"
        self.addSubview(textField)
        textField.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 16).active = true
        textField.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: 8).active = true
        textField.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 10).active = true
        textField.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -10).active = true
    }

    func customizeWithDatePicker(){
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(datePicker)
        datePicker.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 16).active = true
        datePicker.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: 8).active = true
        datePicker.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        datePicker.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    }
    
    

    
    
}

