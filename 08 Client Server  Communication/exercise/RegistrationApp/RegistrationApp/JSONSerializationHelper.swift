//
//  JSONSerializationHelper.swift
//  RegistrationApp
//
//  Created by Johannes Flemke on 31/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class JSONSerializationHelper : SerializationStrategy
{
    
    func loadCourses() -> [CourseTimeslot] {
        var coursesJSONURL = NSBundle.mainBundle().URLForResource("courses", withExtension: "json")
        
        var courses : [CourseTimeslot]?
        
        if let coursesData = NSData.dataWithContentsOfURL(coursesJSONURL!, options: .DataReadingUncached, error: nil)
        {
            courses = self.coursesFromJSONData(coursesData)
        }
        
        return courses!
    }
    
    /**
    *
    */
    func coursesFromJSONData(data: NSData) -> [CourseTimeslot] {
       
        
        var courses : [CourseTimeslot] = [CourseTimeslot]()
        
        var error:NSError?
        if let jsonArray: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error)
        {
            courses = coursesFromArray(jsonArray as [Dictionary<String, String>])
        }
        
        if let err = error? {
            println("Error: %@", err.localizedDescription)
            println("Desc: %@", err.description)
        }

        
        return courses
    }
    
    func coursesFromArray(array: [NSDictionary]) -> [CourseTimeslot] {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        
        var courses : [CourseTimeslot] = [CourseTimeslot]()
        
        // go through all dicts in the returned array of dicts
        for typeDict in array {
            // create CourseType
            var type = CourseType(identifier: typeDict["identifier"] as String,
                name: typeDict["name"] as String,
                description: typeDict["descriptionText"] as String)
            
            // collect all timeslots
            for slotDict in typeDict["timeslots"] as [NSDictionary] {
                let slot = CourseTimeslot(identifier: slotDict["identifier"] as String,
                    startTime: dateFormatter.dateFromString(slotDict["startTime"] as NSString)!,
                    endTime: dateFormatter.dateFromString(slotDict["endTime"] as NSString)!,
                    course: type,
                    location: slotDict["room"] as String)
                
                // add slot to coursetype
                type.timeslots.append(slot)
                // add timeslot to all slots
                courses.append(slot)
            }
        }
        
        return courses
    }
    
    
    func loadRegistrations() -> Student {
        // 1. get the data
        var studentJSONURL = NSBundle.mainBundle().URLForResource("student", withExtension: "json")
        
        var student : Student?
        
        if let studentData = NSData.dataWithContentsOfURL(studentJSONURL!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        {
            student = self.studentFromJSONData(studentData)
        }
        
        return student!
    }
    
    
    private func studentFromJSONData(data: NSData) -> Student {
        var student : Student?
        
        // 2. Deserialize data
        if let jsonDict: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
        {
            var studDict = jsonDict as NSDictionary
            student = studentFromDictionary(studDict)
        }
        
        return student!
    }
    
    
    func studentFromDictionary(dictionary: NSDictionary) -> Student {
        // 3. Store data into object
        
        var student : Student?
        student = Student(identifier: dictionary["identifier"] as String, username: dictionary["name"] as String)
        
        return student!
        

    }
    
    func studentsFromJSONData(data: NSData) -> [Student] {
        
        var students : [Student]?
        var error: NSError?
        
        if let jsonArray: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) {
            
            let studentDictionaries = jsonArray as [NSDictionary]
            students = studentsFromArrayOfDictionary(studentDictionaries)
        }
        
        if let error = error {
            println(error)
        }
        
        return students!
    }
    
    func studentsFromArrayOfDictionary(arrayOfDictionary: [NSDictionary]) -> [Student] {
        var studentsList = [Student]()
        
        for student in arrayOfDictionary {
            
            var studentNow : Student
            
            studentNow = Student(identifier: student["identifier"] as String, username: student["name"] as String)
            
            studentsList.append(studentNow)
        }
        
        return studentsList
        
    }
    
    func storeRegistrations(student: Student) {
        var studentJSONURL = NSBundle.mainBundle().URLForResource("student", withExtension: "json")
        
        // 1. create JSON object
        var jsonDict : [String:AnyObject] = [:]
        jsonDict["identifier"] = student.identifier!
        jsonDict["username"] = student.username!
        
        // add registrations
        var registrationArray = [[String:AnyObject]]()
        for registration in student.registrations {
            registrationArray.append(["identifier":registration.identifier!,
                "courseTimeslotID":registration.courseTimeslot!.identifier!])
        }
        
        jsonDict["registrations"] = registrationArray
        
        // 2. serialize it
        if let jsonData = NSJSONSerialization.dataWithJSONObject(jsonDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        {
            // 3. store data
            if let fileURL = studentJSONURL?.path?
            {
                jsonData.writeToFile(fileURL, atomically: true)
                    
                // also for debugging to documents directory
                let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as [NSURL]
                let docDir = urls[urls.count - 1].path! + "/student.json"
                println("%@", docDir)
                    
                jsonData.writeToFile(docDir, atomically: true)
            }
            
        }
    
    }
    
    func registrationToJSON(student: Student ,registration: Registration) -> [String : AnyObject] {
        var registrationJSON = [String : AnyObject]()
        if let student_id = student.identifier {
            registrationJSON["student"] = student_id
        }
        if let courseTimeslot_id = registration.courseTimeslot?.identifier {
            registrationJSON["courseTimeslot"] = courseTimeslot_id
        }
        return registrationJSON
    }
    
    func addRegistrationFromDictionary(student: Student!, registrationDictionary: NSDictionary) -> Registration {
        
        println(registrationDictionary)

        
        var registration: Registration?
        
        if let slot = DataManager.sharedDataManager.getTimeslotForIdentifier(registrationDictionary["courseTimeslot"] as String) {
            println(slot.identifier!)
            println(student.identifier!)
            let identifier: String = registrationDictionary["identifier"] as String
            registration = Registration(identifier: identifier, student: student, courseTimeslot: slot)
        }
    
        
        return registration!
    }
    
    func addRegistrationsFromArray(student: Student!, registrationsArray: [NSDictionary]) -> [Registration] {
        
        var registrations: [Registration] = [Registration]()
        
        for registrationDictionary in registrationsArray {
            if let slot = DataManager.sharedDataManager.getTimeslotForIdentifier(registrationDictionary["courseTimeslot"] as String) {
                let registration = Registration(identifier: registrationDictionary["identifier"] as String, student: student, courseTimeslot: slot)
                registrations.append(registration)
            }
        }
        
        return registrations
    }
}
