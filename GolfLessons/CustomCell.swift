//
//  CustomCell.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 05.04.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit

class CustomCell : UITableViewCell {
    
    var textField:UITextField!
    
    var textFieldContent = String(){
        didSet{
            
            guard let textField = textField else{return}
            
            textField.text = textFieldContent
        }
    }
    
        override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpTextField()
            
        
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        if !editing{
            textField.resignFirstResponder()
        }
    }

    
    func setUpTextField(){
        
        self.textField = UITextField()
        textField!.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(textField!)
        textField!.leftAnchor.constraintEqualToAnchor(self.contentView.leftAnchor, constant: 16).active = true
        textField!.rightAnchor.constraintEqualToAnchor(self.contentView.rightAnchor, constant: 8).active = true
        textField!.topAnchor.constraintEqualToAnchor(self.contentView.topAnchor, constant: 10).active = true
        textField!.bottomAnchor.constraintEqualToAnchor(self.contentView.bottomAnchor, constant: -10).active = true
        
        
    }
    
    
        
}