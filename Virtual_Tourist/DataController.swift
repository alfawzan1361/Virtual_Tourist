//
//  DataController.swift
//  Virtual_Tourist
//
//  Created by AF on 11/27/19.
//  Copyright © 2019 amaf. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistantContainer: NSPersistentContainer
    
    static let shared = DataController(modelName: "VirtualTourist")
    
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    var backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    private func configureContexts() {
        backgroundContext = persistantContainer.newBackgroundContext()
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completionHandler: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores() {
            (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autosaveViewContext()
            self.configureContexts()
        }
    }
}

extension DataController {
    func autosaveViewContext(interval:TimeInterval = 30) {
        guard interval > 0 else {
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autosaveViewContext()
        }
    }
}
