//
//  HydrantStore.swift
//  Hydrants
//
//  Created by Paul Baker on 3/26/19.
//  Copyright © 2019 Paul Baker. All rights reserved.
//

import Foundation
import UIKit

class HydrantStore {
    
    var hydrantUpdates: [HydrantUpdate] = []
    var imageStore: ImageStore
    
    let hydrantArchiveURL: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectory.first!
        return documentDirectory.appendingPathComponent("hydrants.archive")
    }()
    
    init() {
        imageStore = ImageStore()
        
        do {
            let data = try Data(contentsOf: hydrantArchiveURL)
            let archivedItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HydrantUpdate]
            hydrantUpdates = archivedItems!
        } catch {
            print("Error unarchiving: \(error)") // This is not a problem if it's the first time the app runs
        }
    }
    
    func addHydrantUpdate(hydrant: HydrantUpdate, image: UIImage) {
        hydrantUpdates.append(hydrant)
        imageStore.setImage(image, forKey: hydrant.imageKey)
        archiveChanges()
    }
    
    func getImage(forKey: String) -> UIImage? {
        return imageStore.image(forKey: forKey)
    }
    
    func archiveChanges() {
        
        do {
            
            let data = try NSKeyedArchiver.archivedData(withRootObject: hydrantUpdates, requiringSecureCoding: false)
            try data.write(to: hydrantArchiveURL)
            print("archived items to  \(hydrantArchiveURL)")
        } catch {
            print("Error archiving items: \(error)")
        }
    }
}
