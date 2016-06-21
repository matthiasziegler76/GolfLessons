//
//  DateFormats.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 21.06.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit


extension NSDate{
    
    func simpleDateString()->String{
        return NSDateFormatter.simpleDateFormatter.stringFromDate(self)
    }
    
    func fullDateString()->String{
        return NSDateFormatter.fullDateFormatter.stringFromDate(self)
    }
}

extension NSDateFormatter{
    
    private static let simpleDateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return formatter
    
    }()
    
    private static let fullDateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE dddd.MM.yyyy HH:mm"
        return formatter
        
    }()
    
}
