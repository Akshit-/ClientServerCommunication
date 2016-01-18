//
//  XMLSerializationHelper.swift
//  RegistrationApp
//
//  Created by Michael Schuster on 31/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class XMLSerializationHelper : NSObject, SerializationStrategy
{
    func loadCourses() -> [CourseTimeslot]
    {
        var courseXMLURL = NSBundle.mainBundle().URLForResource("courses", withExtension: "xml")

        var courseTimeslots : [CourseTimeslot] = []
        
        if let courseXMLData = NSData.dataWithContentsOfURL(courseXMLURL!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        {
            var courseXMLParser = CourseXMLParser()
            var courses = courseXMLParser.courseTypesFromXMLData(courseXMLData)
            
            for course in courses
            {
                courseTimeslots += course.timeslots
            }
        }

        return courseTimeslots
    }
    
    func loadRegistrations() -> Student
    {
        var studentXMLURL = NSBundle.mainBundle().URLForResource("student", withExtension: "xml")
        
        var student : Student?
        
        if let studentXMLData = NSData.dataWithContentsOfURL(studentXMLURL!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        {
            var studentXMLParser = StudentXMLParser()
            student = studentXMLParser.studentFromXMLData(studentXMLData)
        }
        
        return student!
    }
    
    func storeRegistrations(student: Student)
    {
        var studentXMLString = StudentXMLParser().xmlStringFromStudent(student)
        //TODO: save
    }
    
    
   
}