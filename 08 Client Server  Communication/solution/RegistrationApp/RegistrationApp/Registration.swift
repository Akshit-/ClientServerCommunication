//
//  Registration.swift
//  RegistrationApp
//
//  Created by Tim Bodeit on 30/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class Registration {
	var identifier: String?
	var student: Student?
	var courseTimeslot: CourseTimeslot?
    
    init(){}
    
    init(student: Student, courseTimeslot: CourseTimeslot) {
        
        self.student = student
        self.courseTimeslot = courseTimeslot
        self.student!.addRegistration(self)        
    }
    
    init(identifier: String, student: Student, courseTimeslot: CourseTimeslot) {
        
        self.identifier = identifier
        self.student = student
        self.courseTimeslot = courseTimeslot
        self.student!.addRegistration(self)
    }
    
    
    
}
