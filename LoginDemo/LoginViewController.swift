//
//  ViewController.swift
//  LoginDemo
//
//  Created by Kostyantyn Runduyev on 11/27/16.
//  Copyright © 2016 Kostyantyn Runduyev. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.email.delegate = self
        self.password.delegate = self
        errorLabel.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if textField == email {
            self.password.becomeFirstResponder()
        } else if textField == password {
            if checkCrudentials() {
                performSegue(withIdentifier: "toMainScreen", sender: nil)
            }
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMainScreen" {
            let mainController = segue.destination as! MainViewController
            mainController.userName = email.text!
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier != "toMainScreen" {
            return true
        }
        return checkCrudentials()
    }
    
    func checkCrudentials() -> Bool {
        if let emailTmp = email.text, let passwordTmp = password.text {
            if !validateEmail(candidate: emailTmp) {
                errorLabel.text = "Please enter correct email"
            } else if passwordTmp.characters.count < MINIMAL_PASSWORD_LENTH {
                errorLabel.text = "Password must contain at leasst \(MINIMAL_PASSWORD_LENTH) symbols"
            } else {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
                request.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(request)
                    var isLoginCorrect = false
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let emailField = result.value(forKey: "email") as? String,
                                let passwordField = result.value(forKey: "password") as? String {
                                if emailField == emailTmp {
                                    isLoginCorrect = true
                                    if passwordField == passwordTmp {
                                        return true
                                    }
                                }
                            }
                        }
                    } else {
                        print("No results")
                    }
                    if isLoginCorrect {
                        errorLabel.text = "Your password is wrong"
                    } else {
                        errorLabel.text = "User with such email not found"
                    }
                    
                } catch {
                    print("Could not fetch results")
                    errorLabel.text = "Error with Data Base"
                    return false
                }
            }
        }
        
        return false
    }
    
}

