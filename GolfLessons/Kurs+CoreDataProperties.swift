//
//  Kurs+CoreDataProperties.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 13.06.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Kurs {

    @NSManaged var date: NSDate?
    @NSManaged var pricePerPerson: NSNumber?
    @NSManaged var theme: String?
    @NSManaged var customers: NSSet?

}
