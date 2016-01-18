//
//  StudentsViewController.swift
//  RegistrationApp
//
//  Created by Akshit Malhotra on 9/26/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation
import UIKit

class StudentsViewController: UITableViewController {
    
    
    let dataManager = DataManager.sharedDataManager

    var students: [Student]?

    var studentsList : [Student]{
        get{
            if let studentsH = students {
                return studentsH
            }else{
                return Array()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {

        updateStudents()
    }
    
    func updateStudents(){
        
        self.dataManager.updateStudents({ (students) -> Void in
    
            self.students = students
            
            self.tableView.reloadData()
            
        }, failure: { (error) -> Void in
            println(error);
            let alert: UIAlertView = UIAlertView(title: "Failure", message: "Can't load the Student List", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        })
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.studentsList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("studentCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.studentsList[indexPath.row].username
        
        return cell
    }

    
    
}