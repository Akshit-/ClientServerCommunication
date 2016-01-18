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
        
        // Exercise 1.2
        
        // change this initialization to initialize the AFHTTPSessionManager with an instance NSURL serving as the baseURL
        
        manager = AFHTTPSessionManager()
        
        // setup the responseSerializer and the requestSerializer of the manager with AFJSONResponseSerializer and AFJSONRequestSerializer as the defaults
        // set the request headers setValue(_ value: String?, forHTTPHeaderField field: String)
    }
    

    
    
    //Exercise 1: Implement the GET for retrieving list of all Students
    
    func updateStudents(success: (students:[Student]) -> Void, failure: (error : NSError!) -> Void) {
        
        
        // Exercise 1.1: using NSURLSession
        
        // TODO initialize the NSURLSessionConfiguration and set the headers: Accept
        
        // TODO initialize the session
        
        // TODO initialize the NSURL object, our URL is http://iosintro-bruegge.in.tum.de:8080/iOSIntroService/rest/students, use the baseUrlString
        
        // TODO initialize the task, use dataTaskWithURL:completionHandler: of NSURLSession
        //      when there's no error initialize a students array with the method studentsFromJSONData serializationHelper
        
        // TODO start the task!
        
        
        
        // Exercise 1.2: using AFNetworking
        
        // TODO Comment out or delete the implementation of NSURLSession
        
        // first implement the init
        
        // TODO call the GET method of the manager, you can just use the the 'students' as URLString
        //      initialize a students array with the method studentsFromArrayOfDictionary of the serializationHelper and call success
        //      in the failure closure call failure
    
        
        
    }
    
    
    //Exercise 2: Implement POST for Register Students
    
    func registerStudent(studentAttributes: Dictionary<String, String>, success:(student:Student!) -> Void, failure: (error : NSError!) -> Void) {
        
        // in our request we don't send a JSON, instead we use the default encoding format, read more about it on Wikipedia: 
        // http://en.wikipedia.org/wiki/Percent-encoding#The_application.2Fx-www-form-urlencoded_type
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.password = studentAttributes["password"]
        
        // TODO call the POST method of the manager on the URL 'students/register', 
        //      use studentAttributes as the parameter, it will actually be put in the body of your request
        
        //      set self.student, with the help of method studentFromDictionary of the serializationHelper
        //      don't forget to call success
        
        //      also to call failure in the failure closure
        
        
        
    }
    
    //Final Exercise Task 1: Implement GET for retrieving list of all Courses
    
    func updateAllAvailableCourses(success: (courses:[CourseTimeslot]) -> Void, failure: (error : NSError!) -> Void) {
        
        // TODO call the GET on the courses
        //      update the variable availableCourseTimeslots with the method coursesFromArray of the serializationHelper
        //      call success
        
        //      call failure in the failure closure

    }
    
    
    //Final Exercise Task 2: Implement POST for Course Registration
    
    func postNewRegistration(registration: Registration, success:(registration: Registration) -> Void, failure: (error : NSError!) -> Void) {
        
        // we now send a JSON again
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // TODO build up the string for the URL first
        //      you can get the IDs from the registration object (don't forget to unwrap the values!)
        
        // TODO we have to make a dictionary for a JSON to POST the registration, look for an appropriate method in the serializationHelper
        
        // TODO now call the POST method of the manager put dictionary as parameters
        //      add the registration the method addRegistrationFromDictionary the serializationHelper
        //      don't forget to call success
        
        //      in the failure closure call failure
        
    }
    
    
    func loginStudent(studentAttributes: Dictionary<String, String>, success: (student:Student!) -> Void, failure: (error : NSError!) -> Void) {
        
        let baseUrl = NSURL(string: baseUrlString)
        manager = AFHTTPSessionManager(baseURL: baseUrl)
        
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        self.password = studentAttributes["password"]
        
        manager.POST("students/login", parameters: studentAttributes, success: { (operation:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
            
            self.student =  self.serializationHelper.studentFromDictionary(responseObject as Dictionary<String, AnyObject>)
            success(student: self.student)
            
            }) { (operation:NSURLSessionDataTask!, error:NSError!) -> Void in
                failure(error: error)
        }
        
    }
    
    
    func updateRegistrations(success: (registrations:[Registration]) -> Void, failure: (error : NSError!) -> Void) {
        
        if let student = self.student {
            
            manager.GET("students/\(student.identifier!)/registrations?username=\(student.username!)&password=\(self.password!)", parameters: nil, success: { (operation:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
                
                let registrations = self.serializationHelper.addRegistrationsFromArray(student, registrationsArray: responseObject as [Dictionary<String, AnyObject>])
                
                success(registrations: registrations)
                
                }) { (operation:NSURLSessionDataTask!, error:NSError!) -> Void in
                    failure(error: error)
            }
            
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
