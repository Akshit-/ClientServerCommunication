//
//  CourseXMLParser.swift
//  RegistrationApp
//
//  Created by Michael Schuster on 12/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class CourseXMLParser : NSObject, NSXMLParserDelegate
{
    private var course : CourseType?
    private var courseTimeslot : CourseTimeslot?
    private var courseTypes : [CourseType]?
    private var elementValue : String?

    func courseTypesFromXMLData(data : NSData)->[CourseType]
    {        
        var parser = NSXMLParser(data: data);
        parser.delegate = self;
        parser.shouldProcessNamespaces = false;
        parser.shouldReportNamespacePrefixes = false;
        parser.shouldResolveExternalEntities = false;
        
        println("Starting to parse");
        parser.parse();
        
        return self.courseTypes!
    }
    
    //MARK: NSXMLParseDelegate
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        self.elementValue = "";
        
        if elementName == "courses"
        {
            self.courseTypes = []
        }
        
        if elementName == "course"
        {
            self.course = CourseType()
            
            if let id = attributeDict["id"] as? NSString
            {
                self.course?.identifier = id
            }
        }
        
        if elementName == "timeslot"
        {
            self.courseTimeslot = CourseTimeslot()
            self.courseTimeslot?.course = self.course!
            
            if let id = attributeDict["id"] as? NSString
            {
                self.courseTimeslot?.identifier = id
            }
        }
        
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if elementName == "timeslot"
        {
            self.course?.timeslots.append(self.courseTimeslot!)
        }
        
        if elementName == "course"
        {
            self.courseTypes?.append(self.course!)
        }

        if elementName == "name"
        {
            self.course?.name = self.elementValue
        }
        
        if elementName == "description"
        {
            self.course?.description = self.elementValue
        }
                
        if elementName == "startDate"
        {
            self.courseTimeslot?.startTime = self.dateFromString(self.elementValue!)
        }
        
        if elementName == "endDate"
        {
            self.courseTimeslot?.endTime = self.dateFromString(self.elementValue!)
        }
        
        if elementName == "location"
        {
            self.courseTimeslot?.location = self.elementValue
        }
        
    }

    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        self.elementValue? += string
    }
    
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!)
    {
        println("Error Parsing: %@", parseError);
    }
    
    
    //MARK: - Date/String Helper
    
    private func dateFromString(dateString : String)->NSDate?
    {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.dateFromString(dateString)
    }
    
    
    private func stringFromDate(date : NSDate)->String
    {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return dateFormatter.stringFromDate(date)
    }

}