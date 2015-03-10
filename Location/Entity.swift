import Foundation
import CoreData

class Entity: NSManagedObject {

    @NSManaged var celsius: String
    @NSManaged var image: String
    @NSManaged var lat: String
    @NSManaged var lot: String
    @NSManaged var summary: String
    @NSManaged var timezone: String
    @NSManaged var currentTime: String
    @NSManaged var humidity: String
    @NSManaged var precipProbability: String
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, celsius: String, image: String, lat: String, lot: String, summary: String, timezone: String, currentTime: String, humidity: String, precipProbability: String) -> Entity {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Entity", inManagedObjectContext: moc) as! Entity
        
        newItem.celsius = celsius
        newItem.image = image
        newItem.lat = lat
        newItem.lot = lot
        newItem.summary = summary
        newItem.timezone = timezone
        newItem.currentTime = currentTime
        newItem.humidity = humidity
        newItem.precipProbability = precipProbability
        
        return newItem
    }


}
