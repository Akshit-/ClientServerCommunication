//
//  CoursesViewController.swift
//  RegistrationApp
//
//  Created by Akshit Malhotra on 8/31/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation
import UIKit

enum CourseSwitchState: Int
{
    case AllCourses = 0
    case MyCourses = 1
}

class CoursesViewController : UITableViewController
{
    @IBOutlet weak var courseSwitchSegmentedControl: UISegmentedControl!
    
	let dataManager = DataManager.sharedDataManager
    
	var courseTimeSlots: [CourseTimeslot]?
    
	var groupedCourseTimeSlots: [[CourseTimeslot]] {
		get {
			var groups = Array<Array<CourseTimeslot>>();

            if let slots = courseTimeSlots {
                for slot in slots {
                    if groups.last?.last?.startTime?.isEqual(slot.startTime) == true {
                        var lastGroup = groups.last!
                        lastGroup.append(slot)
                        groups[groups.count-1] = lastGroup
                    } else {
                        var newGroup = [slot]
                        groups.append(newGroup)
                    }
                }
            }
            
			return groups;
		}
	}
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        
        if courseSwitchSegmentedControl.selectedSegmentIndex == CourseSwitchState.AllCourses.toRaw() {
            updateAllCourses()
            
        } else if courseSwitchSegmentedControl.selectedSegmentIndex == CourseSwitchState.MyCourses.toRaw() {
            updateRegisteredCourses()
        }
    }
    
    func updateAllCourses() {
        self.dataManager.updateAllAvailableCourses({(courses) -> Void in
            
            self.courseTimeSlots = courses
            self.tableView.reloadData()
            
            }, failure: { (error) -> Void in
                let alert: UIAlertView = UIAlertView(title: "Failure", message: "Can't load the courses", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
        })
    }
    
    func updateRegisteredCourses() {

        self.dataManager.updateRegistrations({ (registrations) -> Void in
            self.courseTimeSlots = map(registrations, {$0.courseTimeslot!})
            self.tableView.reloadData()
            
        }, failure: { (error) -> Void in
            println(error)
            let alert: UIAlertView = UIAlertView(title: "Failure", message: "Can't load the registrations", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        })
    }
		
    //MARK: TableViewDelegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.groupedCourseTimeSlots.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupedCourseTimeSlots[section].count
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionGroup = self.groupedCourseTimeSlots[section]
		if let startDate = sectionGroup.last?.startTime {
			return NSDateFormatter.localizedStringFromDate(startDate, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
		} else {
			return ""
		}
	}
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("courseCell", forIndexPath: indexPath) as CoursesTableViewCell
        
        let courseTimeSlot = self.groupedCourseTimeSlots[indexPath.section][indexPath.row]
        cell.titleLabel.text = courseTimeSlot.course?.name
        cell.locationLabel.text = courseTimeSlot.location
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let courseTypeViewController = segue.destinationViewController as? CourseTypeViewController
        {
            let selectedIndexPath = self.tableView.indexPathForSelectedRow()
            let courseTimeSlot = self.groupedCourseTimeSlots[selectedIndexPath!.section][selectedIndexPath!.row]
            
            courseTypeViewController.courseTimeSlot = courseTimeSlot
        }
    }
    
    @IBAction func courseSegmentedControlValueChanged(segmentedControl : UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == CourseSwitchState.AllCourses.toRaw()
        {
            println("Showing all courses")
            updateAllCourses()
        }
        else if segmentedControl.selectedSegmentIndex == CourseSwitchState.MyCourses.toRaw()
        {
            println("Showing only user courses")
            updateRegisteredCourses()
        }
    }
    
}
