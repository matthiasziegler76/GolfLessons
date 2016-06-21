//
//  MainTableViewController.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 18.06.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // coredata stack is not needed because of nsoperation based context delivery
        // coredata stack as a singleton is generally not recommended practice
        
        /*if segue.identifier == "ShowLessons"{
            let controller = segue.destinationViewController as! LessonsTableViewController
            controller.managedObjectContext = self.managedObjectContext
        }*/
    }

    
}
