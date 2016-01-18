//
//  LoginViewController.swift
//  RegistrationApp
//
//  Created by Akshit Malhotra on 8/31/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController
{
    
    @IBOutlet weak var usernameTextField: UITextField!
    var coursesVC: CoursesViewController!;
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func login(sender: AnyObject)
    {
        var username = self.usernameTextField.text!
        var password = self.passwordTextField.text!
        var studentDictionary = ["username": username, "password": password]
        
        DataManager.sharedDataManager.loginStudent(studentDictionary, success: { (student) -> Void in
            
            self.showCoursesViewController()
            }) { (error) -> Void in
                println(error)
                let alert: UIAlertView = UIAlertView(title: "Failure", message: "Something went wrong with your login, try again. \n Error code: \(error.code)", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
        }
        
        
    }
    
    @IBAction func registerButtonPressed()
    {
        var username = self.usernameTextField.text!
        var password = self.passwordTextField.text!
        var studentDictionary = ["username": username, "password": password]
        
        
        DataManager.sharedDataManager.registerStudent(studentDictionary, success: { (student) -> Void in
            
            let alert: UIAlertView = UIAlertView(title: "Success", message: "Successfully registered, your ID is \(student.identifier!)", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.showCoursesViewController()
            
        }) { (error) -> Void in
            println(error)
            let alert: UIAlertView = UIAlertView(title: "Failure", message: "Something went wrong with your registration, try again. \n Error code: \(error.code)", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }

    }
    
    private func showCoursesViewController()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //let vc = storyboard.instantiateViewControllerWithIdentifier("courses") as UIViewController;
        
        //let vc = storyboard.instantiateViewControllerWithIdentifier("students") as UIViewController;

        let vc = storyboard.instantiateViewControllerWithIdentifier("home") as UIViewController;
        
        
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
}