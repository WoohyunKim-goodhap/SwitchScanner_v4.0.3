//
//  UserData.swift
//  switchPriceKana
//
//  Created by Woohyun Kim on 2020/09/26.
//  Copyright © 2020 Woohyun Kim. All rights reserved.
//

import Foundation


struct UserData{
    var recordTitle: String
    var recordCountryName: String
    var recordMinPrice: String

    static var recordTime: String {
        let currentDateTime = Date()
        let userCalendar = Calendar.current
        
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second
        ]
        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
        return "\(dateTimeComponents.year!)/\(dateTimeComponents.month!)/\(dateTimeComponents.day!)"
    }
}

var chartPrices = [Double]()
var dateSeparator = [String]()

var selectedUrl = URL(string: "")
var gameTitelForChart = ""


var priceForAlarm : String = ""
var titleForAlarm : String = ""
var currencyForAlarm : String = ""
var alarmStatusIson : Bool = false

var userToken : String = ""
var userFCMToken : String = ""
