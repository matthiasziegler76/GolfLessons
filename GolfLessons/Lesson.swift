//
//  Lesson.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 24.02.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import Foundation
import CoreData


class Lesson: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    var dateFormatter:NSDateFormatter {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd. MMMM yyyy HH:mm"
        
        return formatter
    }
    
    func csv() ->String{
        
        let name = customer?.firstName ?? ""
        let lastname = customer?.lastName ?? ""
        let dateString = dateFormatter.stringFromDate(date!) ?? ""
        let payedString = "Bezahlt: \(payed!)" ?? ""
        let amountPayed = "\(amount!)" ?? ""
        let lessonDuration = "\(duration!)" ?? ""
        
        return "\(dateString),\(lessonDuration),\(lastname),\(name),\(payedString),\(amountPayed)\n"
    }
}
