import UIKit
import CoreLocation


protocol MapViewControllerDelegate {
    func ForecastViewControllerDidFinish(controller:ForecastViewController, model: Entity)
}

class ForecastViewController: UIViewController, CLLocationManagerDelegate {
    
    private let apiKey = "fc4e12f81d1e0bb9882bf3b14e67b2a9"
    
    @IBOutlet weak var timezoneLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var gettingDataIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var currentWeather: Current!
    var lat: Double!
    var lot: Double!
    var delegate: MapViewControllerDelegate?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var entity: Entity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gettingDataIndicator.startAnimating()
        if entity != nil {
            gettingDataIndicator.hidden = true
            saveButton.enabled = false
            
            self.timezoneLabel.text = entity.timezone
            self.temperatureLabel.text = (entity.celsius as NSString).substringWithRange(NSRange(location: 0, length: count(entity.celsius) - 2))
            self.iconView.image = UIImage(named: entity.image)
            self.currentTimeLabel.text = "At \(entity.currentTime) it is"
            self.humidityLabel.text = entity.humidity
            self.precipitationLabel.text = entity.precipProbability
            self.summaryLabel.text = entity.summary
        }
        else {
            getCurrentWeatherData()
        }
    }
    
    func getCurrentWeatherData() -> Void {
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "\(lat),\(lot)", relativeToURL: baseURL)
        println(forecastURL)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if (error == nil) {
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as! NSDictionary
                
                self.currentWeather = Current(weatherDictionary: weatherDictionary)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.timezoneLabel.text = "\(self.currentWeather.timezone)"
                    self.temperatureLabel.text = String(format: "%.0f", self.currentWeather.temperature)
                    self.iconView.image = self.currentWeather.icon!
                    self.currentTimeLabel.text = "At \(self.currentWeather.currentTime!) it is"
                    self.humidityLabel.text = "\(self.currentWeather.humidity)"
                    self.precipitationLabel.text = "\(self.currentWeather.precipProbability)"
                    self.summaryLabel.text = "\(self.currentWeather.summary)"
                    
                    //Stop refresh animation
                    /*self.refreshActivityIndicator.stopAnimating()
                    self.refreshActivityIndicator.hidden = true
                    self.refreshButton.hidden = false
                    */
                    self.gettingDataIndicator.hidden = true
                })
                
            }
            else {
                
                let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error!", preferredStyle: .Alert)
                
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: {
                    action in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                networkIssueController.addAction(okButton)
                
                self.presentViewController(networkIssueController, animated: true, completion: nil)
                
            }
            
        })
        
        downloadTask.resume()
    }
    
    @IBAction func canselView(sender: UIBarButtonItem) {
       dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func savePoint(sender: UIBarButtonItem) {
        if (gettingDataIndicator.hidden == true && delegate != nil) {
            let entity = Entity.createInManagedObjectContext(managedObjectContext!, celsius: "\(self.currentWeather.temperature)", image: self.currentWeather.iconName!, lat: "\(self.lat)", lot: "\(self.lot)", summary: self.currentWeather.summary, timezone: self.currentWeather.timezone, currentTime: self.currentWeather.currentTime!, humidity: "\(self.currentWeather.humidity)", precipProbability: "\(self.currentWeather.precipProbability)")
            managedObjectContext!.save(nil)
            delegate!.ForecastViewControllerDidFinish(self, model: entity)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

