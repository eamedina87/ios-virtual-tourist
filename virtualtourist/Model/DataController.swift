//
//  DataController.swift
//  virtualtourist
//
//  Created by Erick Medina on 13/9/18.
//  Copyright © 2018 Erick Medina. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    
    let persistentContainer : NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completionHandler: (()->Void)? = nil){
        persistentContainer.loadPersistentStores(){
            storeDescription, error in
            guard (error==nil) else {
                fatalError(error!.localizedDescription)
            }
            completionHandler?()
        }
    }
}
