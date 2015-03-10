import Foundation
import UIKit

struct Current {
    
    var currentTime: String?
    var temperature: Double
    var humidity: Double
    var precipProbability: Double
    var summary: String
    var icon: UIImage?
    var iconName: String?
    var timezone: String
    
    init(weatherDictionary: NSDictionary) {
        timezone = weatherDictionary["timezone"] as! String
        let currentWeather = weatherDictionary["currently"] as! NSDictionary
        
        temperature = currentWeather["temperature"] as! Double
        temperature = round((temperature - 32) / 1.8)
        humidity = currentWeather["humidity"]as! Double
        precipProbability = currentWeather["precipProbability"]as! Double
        summary = currentWeather["summary"] as! String
        
        let currentTimeIntVale = currentWeather["time"] as! Int
        currentTime = dateStringFromUnixTime(currentTimeIntVale)
        
        let iconString = weatherIconFromString(currentWeather["icon"] as! String)
        icon = UIImage(named: iconString)
        iconName = iconString
    }
    
    func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    func weatherIconFromString(stringIcon: String) -> String {
        var imageName: String
        
        switch stringIcon {
        case "clear-day":
            imageName = "clear-day"
        case "clear-night":
            imageName = "clear-night"
        case "rain":
            imageName = "rain"
        case "snow":
            imageName = "snow"
        case "sleet":
            imageName = "sleet"
        case "wind":
            imageName = "wind"
        case "fog":
            imageName = "fog"
        case "cloudy":
            imageName = "cloudy"
        case "partly-cloudy-day":
            imageName = "partly-cloudy"
        case "partly-cloudy-night":
            imageName = "cloudy-night"
        default:
            imageName = "default"
        }
        
        return imageName
    }
    
}
