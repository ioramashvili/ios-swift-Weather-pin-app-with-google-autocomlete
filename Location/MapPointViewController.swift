import UIKit
import CoreData

protocol MapPointViewControllerDelegate {
    func mapPointViewControllerDidFinish(controller: MapPointViewController, isDelete: Bool);
}

class MapPointViewController: UIViewController, UITableViewDataSource , UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    var entity = [Entity]()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var isDeleted: Bool = false
    var delegate: MapPointViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLog()
        tableView.reloadData()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "Entity")
        let sortDescriptor = NSSortDescriptor(key: "image", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Entity] {
            entity = fetchResults
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails" {
            var c = segue.destinationViewController as! ForecastViewController
            c.entity = entity[(sender as! NSIndexPath).row]
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entity.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath) as! PointTableViewCell
        cell.summaryImage.image = UIImage(named:entity[indexPath.row].image)
        cell.summary.text = entity[indexPath.row].summary
        var c = entity[indexPath.row].celsius as NSString
        cell.temperature.text = c.substringWithRange(NSRange(location: 0, length: c.length - 2)) + "º"
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        performSegueWithIdentifier("showDetails", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            let logItemToDelete = entity[indexPath.row]
            entity.removeAtIndex(indexPath.row)
            managedObjectContext?.deleteObject(logItemToDelete)
            managedObjectContext!.save(nil)
            isDeleted = true
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    @IBAction func closeView(sender: UISwipeGestureRecognizer) {
        if(delegate != nil){
            delegate.mapPointViewControllerDidFinish(self, isDelete: isDeleted)
        }
    }
    @IBAction func Cancel(sender: UIBarButtonItem) {
        if(delegate != nil){
            delegate.mapPointViewControllerDidFinish(self, isDelete: isDeleted)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(count(searchText) == 0) {
            self.view.endEditing(true)
        }
        fetchLog()
        entity = count(searchText) > 0 ? entity.filter{ $0.summary.lowercaseString.rangeOfString(searchText.lowercaseString) != nil } : entity
        tableView.reloadData()
    }
}
