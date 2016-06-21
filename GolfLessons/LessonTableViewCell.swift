//
//  LessonTableViewCell.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 18.06.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit

class LessonTableViewCell: UITableViewCell {

    var lesson:Lesson!{
        
        didSet{
            self.setUp()
        }
    }
    
    
    @IBOutlet weak var colorBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setUp(){
        
        let firstName = lesson.customer?.firstName ?? ""
        let lastName = lesson.customer?.lastName ?? ""
        let type = lesson.lessonType?.type ?? ""
        
        self.titleLabel.text = "\(lastName) \(firstName)"
        
        let date = lesson.date?.simpleDateString() ?? "no date"
        self.subTitleLabel.text = date + " - " + type
        
        if lesson.lessonType?.type == "Privat"{
            self.colorBackgroundView.backgroundColor = UIColor.orangeColor()
            self.titleLabel.textColor = UIColor.whiteColor()
            self.subTitleLabel.textColor = UIColor.whiteColor()
        }
        
        if lesson.lessonType == nil{
            self.titleLabel.textColor = UIColor.blackColor()
            self.subTitleLabel.textColor = UIColor.blackColor()
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
