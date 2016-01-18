//
//  StudentXMLParser.swift
//  RegistrationApp
//
//  Created by Michael Schuster on 12/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class StudentXMLParser : NSObject, NSXMLParserDelegate
{
    //MARK: - Serialization
    
    func xmlStringFromStudent(student : Student)->String
    {
        var xmlString : String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        
        xmlString += "<student id = \"" + student.identifier! + "\">"
        xmlString += "<username>" + student.username! + "</username>"
        
        xmlString += "<registrations>"
        
        for registration in student.registrations
        {
            xmlString += "<registration id = \"" + student.identifier! + "\">"

            xmlString += "<timeslotIdentifier>" + registration.courseTimeslot!.identifier! + "</timeslotIdentifier>"

            xmlString += "</registration>"
        }
        
        xmlString += "</registrations>"
        xmlString += "</student>"
        
        return xmlString
    }
    
    //MARK: - Deserialization
    
    private var student : Student?
    private var elementValue : String?
    private var registration : Registration?

    func studentFromXMLData(data : NSData)->Student?
    {
        var parser = NSXMLParser(data: data);
        parser.delegate = self;
        parser.shouldProcessNamespaces = false;
        parser.shouldReportNamespacePrefixes = false;
        parser.shouldResolveExternalEntities = false;
        
        println("Starting to parse");
        parser.parse();
        
        return self.student
    }
    
    //MARK: NSXMLParseDelegate
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        self.elementValue = "";
        
        if elementName == "student"
        {
            self.student = Student()
            
            if let id = attributeDict["id"] as? NSString
            {
                self.student?.identifier = id
            }

        }
        if elementName == "registration"
        {
            self.registration = Registration()
            self.registration?.student = self.student
            
            if let id = attributeDict["id"] as? NSString
            {
                self.registration?.identifier = id
            }
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if elementName == "username"
        {
            self.student?.username = self.elementValue
        }
        
        if elementName == "timeslotIdentifier"
        {
            //TODO:
//            if let timeslot = (FirstDataManager.sharedDataManager as FirstDataManager).getTimeslotForIdentifier(self.elementValue!)
//            {
//                self.registration?.courseTimeslot = timeslot
//            }
        }
        
        if elementName == "registration"
        {
            self.student?.registrations.append(self.registration!)
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
    

}