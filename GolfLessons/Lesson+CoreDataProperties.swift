//
//  Lesson+CoreDataProperties.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 24.02.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Lesson {

    @NSManaged var date: NSDate?
    @NSManaged var duration: NSNumber?
    @NSManaged var payed: NSNumber?
    @NSManaged var amount: NSNumber?

}
