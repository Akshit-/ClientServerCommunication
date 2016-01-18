//
//  CourseType.swift
//  RegistrationApp
//
//  Created by Tim Bodeit on 31/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit

class CourseType {
	var identifier: String?
	var name: String?
	var description: String?
    var timeslots : [CourseTimeslot] = []
    
    init(){}
    
    init(identifier: String, name: String, description: String){
        self.identifier = identifier
        self.name = name
        self.description = description
    }
}
