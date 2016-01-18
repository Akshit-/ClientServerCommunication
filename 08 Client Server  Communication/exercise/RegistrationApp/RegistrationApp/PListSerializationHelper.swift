//
//  PListSerializationHelper.swift
//  RegistrationApp
//
//  Created by Johannes Flemke on 08/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class PListSerializationHelper : SerializationStrategy
{
    func loadCourses() -> [CourseTimeslot] {
        var coursesPListURL = NSBundle.mainBundle().URLForResource("courses", withExtension: "plist")
        
        var courses : [CourseTimeslot]?
        
        if let coursesData = NSData.dataWithContentsOfURL(coursesPListURL!, options: .DataReadingUncached, error: nil)
        {
            courses = self.coursesFromPListData(coursesData)
        }
        
        return courses!
    }
    
    /**
    *
    */
    func coursesFromPListData(data: NSData) -> [CourseTimeslot] {
        var courses : [CourseTimeslot] = [CourseTimeslot]()
        
        if let plist: AnyObject = NSPropertyListSerialization.propertyListWithData(data, options: Int(NSPropertyListMutabilityOptions.Immutable.toRaw()), format: nil, error: nil)
        {
            // go through all dicts in the returned array of dicts
            for typeDict in plist as [NSDictionary] {
                // create CourseType
                var type = CourseType(identifier: typeDict["identifier"] as String,
                                      name: typeDict["name"] as String,
                                      description: typeDict["description"] as String)
                
                // collect all timeslots
                for slotDict in typeDict["timeslots"] as [NSDictionary] {
                    let slot = CourseTimeslot(identifier: slotDict["identifier"] as String,
                                              startTime: slotDict["startTime"] as NSDate,
                                              endTime: slotDict["endTime"] as NSDate,
                                              course: type,
                                              location: slotDict["location"] as String)
                    
                    // add slot to coursetype
                    type.timeslots.append(slot)
                    // add timeslot to all slots
                    courses.append(slot)
                }
            }
        }
        
        
        return courses
    }
    
    
    func loadRegistrations() -> Student {
        // 1. get the data
        var studentPListURL = NSBundle.mainBundle().URLForResource("student", withExtension: "plist")
        
        var student : Student?
        
        if let studentData = NSData.dataWithContentsOfURL(studentPListURL!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        {
            student = self.studentFromPListData(studentData)
        }
        
        return student!
    }
    
    
    func studentFromPListData(data: NSData) -> Student {
        var student : Student?
        
        // 2. Deserialize data
        if let plist: AnyObject = NSPropertyListSerialization.propertyListWithData(data, options: Int(NSPropertyListMutabilityOptions.Immutable.toRaw()), format: nil, error: nil)
        {
            // 3. Store data into object
            var studDict = plist as NSDictionary
            
            student = Student(identifier: studDict["identifier"] as String, username: studDict["username"] as String)
            
            // get all registrations
            for regDict in studDict["registrations"] as NSArray {
                // search for slot
                if let slot = DataManager.sharedDataManager.getTimeslotForIdentifier(regDict["courseTimeslotID"] as String) {
                    // init registration
                    let registration = Registration(identifier: regDict["identifier"] as String, student: student!, courseTimeslot: slot)
                    // add it to the student
                    student!.registrations.append(registration)
                }
            }
            
        }
    
        return student!
    }
    
    
    func storeRegistrations(student: Student) {
        // 1. create plist
        var plist : [String:AnyObject] = [:]
        plist["identifier"] = student.identifier!
        plist["username"] = student.username!
        
        // organize registrations
        var registrationArray = [[String:AnyObject]]()
        for registration in student.registrations {
            registrationArray.append(["identifier":registration.identifier!,
                                      "courseTimeslotID":registration.courseTimeslot!.identifier!])
        }
        
        // add registrations
        plist["registrations"] = registrationArray
        
        // 2. serialize it
        if let plistData = NSPropertyListSerialization.dataWithPropertyList(plist, format: NSPropertyListFormat.XMLFormat_v1_0, options: 0, error: nil)
        {
            // write it to documents directory
            let docDir = DataManager.sharedDataManager.getDocumentDirectory() + "/student.plist"
            println("%@", docDir)
                
            plistData.writeToFile(docDir, atomically: true)
        }
    }

}
