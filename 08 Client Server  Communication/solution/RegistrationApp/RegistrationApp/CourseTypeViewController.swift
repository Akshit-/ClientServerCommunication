//
//  CourseTypeViewController.swift
//  RegistrationApp
//
//  Created by Akshit Malhotra on 8/31/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation
import UIKit

class CourseTypeViewController : UITableViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var registrationButton: UIBarButtonItem!

    var courseTimeSlot : CourseTimeslot?
    
    override func viewDidLoad() {
        if let courseName = self.courseTimeSlot?.course?.name {
            self.title = courseName
            self.titleLabel.text = courseName
        }
        self.timeLabel.text = self.formattedTimeString
        if let location = self.courseTimeSlot?.location {
            self.locationLabel.text = location
        }
        if let description = self.courseTimeSlot?.course?.description {
            self.descriptionLabel.text = description;
        }
    }
    
    var formattedTimeString : String {
        let startTime = self.courseTimeSlot?.startTime
        let endTime = self.courseTimeSlot?.endTime
            
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "dd.MM.yyyy HH:mm"

        var startTimeString = dateFormater.stringFromDate(startTime!)
        dateFormater.dateFormat = "HH:mm"
        var endTimeString = dateFormater.stringFromDate(endTime!)
            
        return "\(startTimeString) - \(endTimeString)"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            var calculationView = UITextView()
            calculationView.text = self.descriptionLabel.text
            calculationView.font = self.descriptionLabel.font
            var size = calculationView.sizeThatFits(CGSizeMake(tableView.bounds.size.width - 30, CGFloat(FLT_MAX)));

            return size.height
        }
        return 44
    }
    
    @IBAction func registerButtonPressed()
    {
        if let courseTimeSlot = self.courseTimeSlot
        {
            var newRegistration = Registration(student: DataManager.sharedDataManager.student!, courseTimeslot: courseTimeSlot)
            
            DataManager.sharedDataManager.postNewRegistration(newRegistration, success: { (registration) -> Void in
                println("Posted registration")
                let alert: UIAlertView = UIAlertView(title: "Success", message: "Successfully registered!", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                self.registrationButton.enabled = false
                newRegistration.identifier = registration.identifier
                
            }, failure: { (error) -> Void in
                println("Failed to post registration")
                println(error)
                let alert: UIAlertView = UIAlertView(title: "Failure", message: "Something went wrong with your registration, try again. \n Error code: \(error.code)", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            })
        }
    }
    
}
