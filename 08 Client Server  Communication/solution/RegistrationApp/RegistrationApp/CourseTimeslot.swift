//
//  CourseTimeslot.swift
//  RegistrationApp
//
//  Created by Tim Bodeit on 31/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit

class CourseTimeslot {
	var identifier: String?
	var startTime: NSDate?
	var endTime: NSDate?
	var course: CourseType?
    var location: String?
    
    init(){}
    
    init(identifier: String, startTime: NSDate, endTime: NSDate, course: CourseType, location: String) {
        self.identifier = identifier
        self.startTime = startTime
        self.endTime = endTime
        self.course = course
        self.location = location
    }
}
