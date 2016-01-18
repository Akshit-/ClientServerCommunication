//
//  Student.swift
//  RegistrationApp
//
//  Created by Tim Bodeit on 31/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit

class Student {
	var identifier: String?
	var registrations = [Registration]()
    var username: String?
    
    init(){}
    
    init(identifier: String, username : String) {
        self.identifier = identifier
        self.username = username
    }
    
    func addRegistration(registration: Registration) {
        self.registrations.append(registration)
    }
    
    func isRegisteredForTimeslot(timeslot : CourseTimeslot)->Bool
    {
        var isRegisteredForTimeslot : Bool = false
        
        for registration in self.registrations
        {
            if registration.courseTimeslot?.identifier == timeslot.identifier
            {
                isRegisteredForTimeslot = true
                break
            }
        }
        
        return isRegisteredForTimeslot
    }
    
}
