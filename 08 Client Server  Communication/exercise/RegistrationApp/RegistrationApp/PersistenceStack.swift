//
//  PersisitenceStack.swift
//  RegistrationApp
//
//  Created by Stefan Kofler on 10.09.14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import CoreData

private let _sharedPersistenceStack = PersistenceStack()

class PersistenceStack {
    var managedObjectContext: NSManagedObjectContext = NSManagedObjectContext()
    private var managedObjectModel: NSManagedObjectModel?
    
    private var storeURL: NSURL {
        var error: NSError?
        var documentsDirectory: NSURL = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: &error)!
        if let documentsDirectoryError = error {
            println("Couldn't get documents directory")
        }
        return documentsDirectory.URLByAppendingPathComponent("db.sqlite")
    }
    
    private var modelURL: NSURL {
        return NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
    }
    
    class var sharedPersistenceStack: PersistenceStack {
        return _sharedPersistenceStack;
    }
    
    init() {
        self.managedObjectModel = NSManagedObjectModel(contentsOfURL: self.storeURL)

        setupManagedObjectContext();
        setupNotificationListeners();
    }
    
    private func setupNotificationListeners() {
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { (notification: NSNotification!) -> Void in
            println("Did save data to database")
        }
    }
    
    private func setupManagedObjectContext() {
        managedObjectContext.undoManager = NSUndoManager()
        managedObjectContext.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        var error: NSError?
        managedObjectContext.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error)
        if let persistentStoreError = error {
            println("error: \(persistentStoreError.localizedDescription)")
            println("rm: '\(storeURL.path)'")
        }
    }
}
