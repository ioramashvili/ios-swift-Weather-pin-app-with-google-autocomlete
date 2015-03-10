import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, MapViewControllerDelegate, GMSMapViewDelegate, MapPointViewControllerDelegate, 
 NSFetchedResultsControllerDelegate, GeoLabLocationDelegate2 {
        
    
    @IBOutlet weak var theMap: GMSMapView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var currentRequest:CLLocationCoordinate2D!
    
    var entity = [Entity]()
    let locationManager = CLLocationManager()
    var isDelete: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theMap.delegate = self
        theMap.myLocationEnabled = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        fetchLog()
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.currentRequest != nil {
            self.performSegueWithIdentifier("goToForecast", sender: self)
            self.currentRequest = nil
        }
        else if isDelete {
            theMap.clear()
            fetchLog()
            isDelete = false
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            theMap.myLocationEnabled = true
            theMap.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            theMap.camera = GMSCameraPosition(target: location.coordinate, zoom: 10, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func getLocationFromAutocomplete2(controller: GooglePlacesAutocomplete, point: CLLocationCoordinate2D) {
        
        self.currentRequest = point
        println(self.currentRequest.latitude)
        println(self.currentRequest.longitude)
    }
    
    func mapPointViewControllerDidFinish(controller: MapPointViewController, isDelete: Bool) {
        self.isDelete = isDelete
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "Entity")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Entity] {
            entity = fetchResults
        }
        
        for i in 0..<entity.count {
            self.addPoint(i, latitude: (entity[i].lat as NSString).doubleValue, longitude: (entity[i].lot as NSString).doubleValue, title: entity[i].summary, subtitle: entity[i].celsius, imageName: entity[i].image)
        }
    }
    
    func ForecastViewControllerDidFinish(controller: ForecastViewController, model: Entity) {
        entity.append(model)
        self.addPoint(entity.count - 1, latitude: (model.lat as NSString).doubleValue, longitude: (model.lot as NSString).doubleValue, title: model.summary, subtitle: model.celsius, imageName: model.image)
        
    }
    
    @IBAction func mapViewChanger(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                theMap.mapType = kGMSTypeNormal
            case 1:
                theMap.mapType = kGMSTypeSatellite
            default:
                theMap.mapType = kGMSTypeHybrid
        }
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.currentRequest = coordinate
        performSegueWithIdentifier("goToForecast", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToForecast" {
            var c = segue.destinationViewController as! ForecastViewController
            c.lot = self.currentRequest.longitude
            c.lat = self.currentRequest.latitude
            self.currentRequest = nil
            c.delegate = self
        }
        else if segue.identifier == "showDetails" {
            var c = segue.destinationViewController as! ForecastViewController
            c.entity = entity[Int((sender as! GMSMarker).zIndex)]
        }
        else if segue.identifier == "goToTableView" {
            var c = segue.destinationViewController as! MapPointViewController
            c.delegate = self
        }
        
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        performSegueWithIdentifier("showDetails", sender: marker)
    }

    
    @IBAction func showUserLocation(sender: UIBarButtonItem) {
        let gpaViewController = GooglePlacesAutocomplete(
            apiKey: "AIzaSyBFnWdszxwlhryAWtBNC83-AzMLJgxE-gI",
            placeType: .Address
        )
        
        gpaViewController.placeDelegate = self
        gpaViewController.secondDelegate = self
        
        presentViewController(gpaViewController, animated: true, completion: nil)

    }
    private func addPoint(index: Int, latitude: Double, longitude: Double, title: String, subtitle: String, imageName: String) {
        var camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 5)
        theMap.camera = camera
        
        var marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        marker.title = "\(title)  \((subtitle as NSString).substringWithRange(NSRange(location: 0, length: count(subtitle) - 2)))" + "º"
        marker.icon = UIImage(named: imageName)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.zIndex = Int32(index)
        marker.map = theMap
    }
    
    @IBAction func varcseguedestinationViewControllerasForecastViewControllercentityentityIntsenderasGMSMarkerzIndexgoToTableView(sender: UIBarButtonItem) {
        
        performSegueWithIdentifier("goToTableView", sender: self)
    }
}

extension ViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        println(place.description)
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
