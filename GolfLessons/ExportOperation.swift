//
//  ExportOperation.swift
//  GolfLessons
//
//  Created by Matthias Ziegler on 22.03.16.
//  Copyright © 2016 Matthias Ziegler. All rights reserved.
//

import UIKit

protocol ExportOperationDelegate{
    
    func exportOperationDidFinishExporting(filePath:String)
}

class ExportOperation : Operation {
    
    var delegate:ExportOperationDelegate?
    let temporaryDirectory = NSTemporaryDirectory()
    let results:[Lesson]!
    
    // MARK: Initialization
    
    init(results:[Lesson]) {
        
        self.results = results
        super.init()
        
        addCondition(MutuallyExclusive<ExportOperation>())
        
    }
    
    
    override func execute() {
       
        let exportFilePath = temporaryDirectory + "export.csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        NSFileManager.defaultManager().createFileAtPath(exportFilePath, contents: NSData(), attributes: nil)
        
        let fileHandle: NSFileHandle?
            do {
                fileHandle = try NSFileHandle(forWritingToURL: exportFileURL)
            } catch {
                let nserror = error as NSError
                print("ERROR: \(nserror)")
                fileHandle = nil
            }
        
        if let fileHandle = fileHandle {
            // 4
            for object in results {
                let journalEntry = object
                
                fileHandle.seekToEndOfFile()
                let csvData = journalEntry.csv().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                fileHandle.writeData(csvData!)
            }
            
            // 5
            fileHandle.closeFile()
            
            self.delegate?.exportOperationDidFinishExporting(exportFilePath)
            finishWithError(nil)    
            
        }
    }
    
    override func finished(errors: [NSError]) {
        guard let firstError = errors.first where userInitiated else { return }
        
        /*
        We failed to write the file on a user initiated operation try and present
        an error.
        */
        
        let alert = AlertOperation()
        
        alert.title = "Unable to write file"
        
        alert.message = "An error occurred while writing the file. \(firstError.localizedDescription). Please try again later."
        
        // No custom action for this button.
        alert.addAction("Retry Later", style: .Cancel)
        
        // Declare this as a local variable to avoid capturing self in the closure below.
        let result = results
        
        /*
        For this operation, the `loadHandler` is only ever invoked if there are
        no errors, so if we get to this point we know that it was not executed.
        This means that we can offer to the user to try loading the model again,
        simply by creating a new copy of the operation and giving it the same
        loadHandler.
        */
        alert.addAction("Retry Now") { alertOperation in
            let retryOperation = ExportOperation(results: result)
            
            retryOperation.userInitiated = true
            
            alertOperation.produceOperation(retryOperation)
        }
        
        produceOperation(alert)
    }


}

