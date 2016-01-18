//
//  SerializationStrategy.swift
//  RegistrationApp
//
//  Created by Michael Schuster on 08/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

protocol SerializationStrategy
{
    func loadCourses()->[CourseTimeslot]
    func loadRegistrations()->Student
    func storeRegistrations(student : Student)
}