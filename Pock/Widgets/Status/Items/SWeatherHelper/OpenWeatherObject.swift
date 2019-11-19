//
//  OpenWeatherObject.swift
//  Pock
//
//  Created by Matteo Rossetto on 19/11/2019.
//  Copyright © 2019 Pierluigi Galdi. All rights reserved.
//

import Cocoa

class OpenWeatherObject: NSObject {

    var iconName : String = ""
    var localityName : String = ""
    var temperatureText : String = ""
    
    var formattedTemperature : String{
        get{
            return "\(self.temperatureText)°C"
        }
    }
}
