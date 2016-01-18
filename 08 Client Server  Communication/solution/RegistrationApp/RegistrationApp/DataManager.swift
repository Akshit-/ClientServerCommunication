//
//  DataManager.swift
//  RegistrationApp
//
//  Created by Tim Bodeit on 30/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation
import AFNetworking

private let _dataManagerInstance = DataManager();

class DataManager {
    
    private let serializationHelper : JSONSerializationHelper = JSONSerializationHelper()
    
    var student: Student?
    var password: String?
    var availableCourseTimeslots:Array<CourseTimeslot>?
    
    let baseUrlString = "http://iosintro-bruegge.in.tum.de:8080/iOSIntroService/rest/"
    var manager : AFHTTPSessionManager
    
    class var sharedDataManager: DataManager {
        return _dataManagerInstance;
    }
    
    init() {
        let baseUrl = NSURL(string: baseUrlString)
        manager = AFHTTPSessionManager(baseURL: baseUrl)
        
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    //1st Exercise : Implement the GET for retrieving list of all Students

    func updateStudents(success: (students:[Student]) -> Void, failure: (error : NSError!) -> Void) {
        
        //Part 1: using NSURLSession        
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Accept": "application/json", "Content-Type": "application/json"]
        
        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        
        let url = NSURL(string: self.baseUrlString + "students")
        
        let task = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if (error != nil) {
                failure(error: error)
                
            } else {
                let students = self.serializationHelper.studentsFromJSONData(data)
                success(students: students)
            }
            
        })
        
        task.resume()
        
        //Part 2: using AFNetworking
        
//        manager.GET("students", parameters: nil, success: { (operation:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
//            
//            let studentsDict = responseObject as [Dictionary<String, AnyObject>]
//            
//            let studentsArray = self.serializationHelper.studentsFromArrayOfDictionary(studentsDict)
//            
//            success(students: studentsArray)
//            
//        }, failure: { (operation:NSURLSessionDataTask!, error:NSError!) -> Void in
//            
//            failure(error: error)
//            
//        })
        
    }
    

    //2nd Exercise : Implement POST for Register Students
    
    func registerStudent(studentAttributes: Dictionary<String, String>, success:(student:Student!) -> Void, failure: (error : NSError!) -> Void) {
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.password = studentAttributes["password"]
        
        manager.POST("students/register", parameters: studentAttributes, success: { (operation:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
            
            let studentDict = responseObject as Dictionary<String, AnyObject>
            
            self.student =  self.serializationHelper.studentFromDictionary(studentDict)
            
            success(student: self.student)
            
        }, failure: { (operation:NSURLSessionDataTask!, error:NSError!) -> Void in
            
            failure(error: error)
            
        })
        
    }
    
    //Final Exercise: Implement GET for retrieving list of all Courses

    func updateAllAvailableCourses(success: (courses:[CourseTimeslot]) -> Void, failure: (error : NSError!) -> Void) {
        
        manager.GET("sessions", parameters: nil, success: { (operation:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
            
            let coursesDict = responseObject as [Dictionary<String, AnyObject>]
            
            self.availableCourseTimeslots = self.serializationHelper.coursesFromArray(coursesDict)
            
            success(courses: self.availableCourseTimeslots!)
            
        }, failure: { (operation:NSURLSessionDataTask!, error:NSError!) -> Void in
            
            failure(error: error)
            
        })
        
    }
    
    
    //Final Exercise: Implement POST for Course Registration
    
    func postNewRegistration(registration: Registration, success:(registration: Registration) -> Void, failure: (error : NSError!) -> Void) {
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let path = "sessions/" + registration.courseTimeslot!.course!.identifier!
            + "/timeslots/" + registration.courseTimeslot!.identifier!
            + "/registrations?"
            + "username=" + self.student!.username! + "&password=" + self.password!
        
        let registrationDict = self.serializationHelper.registrationToJSON(self.student!, registration: registration);
        
        
        manager.POST(path, parameters: registrationDict, success: { (operation:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
            
            let responseDict = responseObject as Dictionary<String, AnyObject>
            
            let registration = self.serializationHelper.addRegistrationFromDictionary(self.student, registrationDictionary: responseDict)
            
            success(registration: registration)
            
        }, failure: { (operation:NSURLSessionDataTask!, error:NSError!) -> Void in
            
            failure(error: error)
            
        })
    }
    
    func loginStudent(studentAttributes: Dictionary<String, String>, success: (student:Student!) -> Void, failure: (error : NSError!) -> Void) {
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        self.password = studentAttributes["password"]
        
        manager.POST("students/login", parameters: studentAttributes, success: { (operation:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
            
            self.student =  self.serializationHelper.studentFromDictionary(responseObject as Dictionary<String, AnyObject>)
            success(student: self.student)
            
            }, failure: { (operation:NSURLSessionDataTask!, error:NSError!) -> Void in
                
                failure(error: error)
                
        })
        
    }
    
    
    func updateRegistrations(success: (registrations:[Registration]) -> Void, failure: (error : NSError!) -> Void) {
        
        if let student = self.student {
            
            manager.GET("students/\(student.identifier!)/registrations?username=\(student.username!)&password=\(self.password!)", parameters: nil, success: { (operation:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
                
                let registrations = self.serializationHelper.addRegistrationsFromArray(student, registrationsArray: responseObject as [Dictionary<String, AnyObject>])
                
                success(registrations: registrations)
                
            }, failure: { (operation:NSURLSessionDataTask!, error:NSError!) -> Void in
                
                failure(error: error)
                
            })
            
        }
        
    }
    
    
    
    func sortTimeslots()
    {
        self.availableCourseTimeslots!.sort { (firstTimeslot, secondTimeslot) -> Bool in
            var result = firstTimeslot.startTime!.compare(secondTimeslot.startTime!)
            return result == NSComparisonResult.OrderedAscending
        }
        
    }
    
    func getTimeslotForIdentifier(identifier: String) -> CourseTimeslot? {
        
        if let slots = availableCourseTimeslots {
            for slot in availableCourseTimeslots! {
                if( slot.identifier == identifier ) {
                    return slot
                }
            }
        }
        
        return nil
    }
    
    func getDocumentDirectory() -> String {
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as [NSURL]
        return urls[urls.count - 1].path!
    }
    
}
