//
//  SWeatherHelper.swift
//  Pock
//
//  Created by Matteo Rossetto on 19/11/2019.
//  Copyright © 2019 Pierluigi Galdi. All rights reserved.
//

import Cocoa
import CoreLocation
import Alamofire

protocol SWeatherHelperDelegate{
    func hasNewLocation(weatherItem:OpenWeatherObject)
}

class SWeatherHelper: NSObject {

    private var locationManager : CLLocationManager?
    public var delegate : SWeatherHelperDelegate?
    private var isUpdatingLocation: Bool = false
    private var currentLocation : CLLocation = CLLocation()
    
    /*override init() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }*/
    
    func startLocationUpdates(){
        
        guard !self.isUpdatingLocation else {return}
        
        self.locationManager = CLLocationManager()
        //locManager.requestAlwaysAuthorization()
        guard let locManager = self.locationManager else {return}
        locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
        self.isUpdatingLocation = true
    }
    
    func stopLocationUpdates(){
        self.delegate = nil
        
        guard self.locationManager != nil else {return}
        self.locationManager?.stopUpdatingLocation()
        self.locationManager = nil
        self.isUpdatingLocation = false
    }
}

extension SWeatherHelper : CLLocationManagerDelegate{
    
    func refreshData(){
        updateLocationData()
    }
    
    func updateLocationData(){
        
        let apiKey = "API_KEY"
        
        let weatherObj = OpenWeatherObject()
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(self.currentLocation.coordinate.latitude)&lon=\(self.currentLocation.coordinate.longitude)&appid=\(apiKey)&units=metric").response{responseData in
            debugPrint(responseData)
            
            if let data = responseData.data{
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                guard json != nil else {
                    print("empty json")
                    return
                }
                
                if let locality = json?["name"] as? String{
                    weatherObj.localityName = locality
                }
                
                if let weather = json?["weather"] as? [Any]{
                    let weatherItem = weather.first as! [String:Any]
                    if let iconName = weatherItem["icon"] as? String{
                        weatherObj.iconName = iconName
                    }
                }
                
                if let main = json?["main"] as? [String:Any]{
                    if let temperature = main["temp"] as? NSNumber{
                        weatherObj.temperatureText = NSString(format:"%.1f",temperature.doubleValue) as String//"\(temperature.intValue)"
                    }
                }
                
                //debugPrint(json)
                //print("location updated")
                self.delegate?.hasNewLocation(weatherItem: weatherObj)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard self.delegate != nil else {
            print("delegate was not set")
            return
        }
        
        guard locations.count > 0 else {
            print("no location returned")
            return
        }
        
        self.currentLocation = locations.first!
        updateLocationData()
    }
}
