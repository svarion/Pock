//
//  SWeatherItem.swift
//  Pock
//
//  Created by Matteo Rossetto on 18/11/2019.
//  Copyright © 2019 Pierluigi Galdi. All rights reserved.
//

import Cocoa
import Defaults
import CoreLocation
import CoreWLAN
import Alamofire

class WeatherWidgetView : NSView {
    
    private let iconView: NSImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 26, height: 26))
    private let widgetView: NSView = NSView(frame: NSRect(x:0,y:0,width:26,height:26))
    private let textLabel: NSTextField = NSTextField(frame: NSRect(x:0,y:16,width:26,height:10))
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addSubview(iconView)
        self.addSubview(textLabel)
    }
    
    func updateWeatherIcon(icon:NSImage){
        self.iconView.image = icon
    }
    
    func updateTemperatureText(text:String){
        self.textLabel.stringValue = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SWeatherItem: StatusItem {
    
    ///Core
    private var weatherHelper: SWeatherHelper = SWeatherHelper()
    private var weatherObject: OpenWeatherObject?
    private var refreshTimer: Timer?
    
    /// UI
    private let iconView: NSImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 26, height: 26))
    //private let widgetView: NSView = NSView(frame: NSRect(x:0,y:0,width:26,height:26))
    //private let textLabel: NSTextField = NSTextField(frame: NSRect(x:0,y:16,width:26,height:10))
    //private let widgetView: WeatherWidgetView = WeatherWidgetView(frame: NSRect(x:0,y:0,width:26,height:36))
    private let stackView: NSStackView = NSStackView(frame: .zero)
    private let bodyView: NSView      = NSView(frame: NSRect(x: 2, y: 2, width: 21, height: 8))
    private let valueLabel: NSTextField = NSTextField(frame: .zero)
    
    init() {
        didLoad()
        reload()
    }
    
    deinit {
        didUnload()
    }
    
    var enabled: Bool{ return Defaults[.shouldShowWeatherItem] }
    
    var title: String  { return "weather" }
    
    var view: NSView {
        //return widgetView
        return stackView
    }
    
    func action() {
        if !isProd { print("[Pock]: Weather icon tapped!") }
    }
    
    func didLoad() {
        
        //self.widgetView.layer?.backgroundColor = NSColor.red.cgColor
        //self.textLabel.textColor = NSColor.white
        //self.textLabel.stringValue = "--°C"
        //self.widgetView.addSubview(iconView)
        //self.widgetView.addSubview(self.textLabel)
        configureValueLabel()
        configureStackView()
        self.weatherHelper.delegate = self
        self.weatherHelper.startLocationUpdates()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60*15, repeats: true, block: { _ in
            self.weatherHelper.refreshData()
        })
    }
    
    func didUnload() {
        self.weatherHelper.stopLocationUpdates()
    }
    
    private func configureValueLabel() {
        valueLabel.font = NSFont.systemFont(ofSize: 13)
        valueLabel.backgroundColor = .clear
        valueLabel.isBezeled = false
        valueLabel.isEditable = false
        valueLabel.sizeToFit()
    }
    
    private func configureStackView() {
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(iconView)
    }
    
    func reload() {
        
        if let iconName = self.weatherObject?.iconName{
            DispatchQueue.main.async { [weak self] in
                
                let resizedIcon = NSImage(named: iconName)?.resized(withSize: NSSize(width:26,height:26))
                self?.iconView.image = resizedIcon
                //self?.widgetView.updateWeatherIcon(icon: resizedIcon!)
                //self?.textLabel.stringValue = self?.weatherObject?.tempText ?? "--°C"
                //self?.widgetView.updateTemperatureText(text: "--°C")
                self?.valueLabel.stringValue = self?.weatherObject?.formattedTemperature ?? "--°C"
                //self?.widgetView.frame = NSRect(x: 0, y: 0, width: 26, height: 26)
                //self?.iconView.frame = NSRect(x: 0, y: 0, width: 26, height: 26)
                //debugPrint(self?.iconView)
            }
        }
    }
}

extension SWeatherItem : SWeatherHelperDelegate{
    func hasNewLocation(weatherItem:OpenWeatherObject) {
        debugPrint(weatherItem)
        
        self.weatherObject = weatherItem
        self.reload()
    }
}
