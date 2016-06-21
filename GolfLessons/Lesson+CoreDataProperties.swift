//
//  Lesson+CoreDataProperties.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 14.06.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Lesson {

    @NSManaged var amount: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var duration: NSNumber?
    @NSManaged var payed: NSNumber?
    @NSManaged var customer: Customer?
    @NSManaged var lessonType: LessonType?

}
