//
//  RegisterViewController.swift
//  LoginDemo
//
//  Created by Kostyantyn Runduyev on 11/27/16.
//  Copyright © 2016 Kostyantyn Runduyev. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var passwordRepeatLabel: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.emailLabel.delegate = self
        self.passwordLabel.delegate = self
        self.passwordRepeatLabel.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if textField == emailLabel {
            self.passwordLabel.becomeFirstResponder()
        } else if textField == passwordLabel {
            self.passwordLabel.becomeFirstResponder()
        } else if textField == passwordRepeatLabel {
            if register() {
                performSegue(withIdentifier: "toMainScreen", sender: nil)
            }
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier != "toMainScreen" {
            return true
        }
        
        let isInputCorrect = register()
        
        return isInputCorrect
        
    }
    
    func register() -> Bool {
        if let emailTmp = emailLabel.text, let passwordTmp = passwordLabel.text, let passwordRepeatTmp = passwordRepeatLabel.text {
            if !validateEmail(candidate: emailTmp) {
                errorLabel.text = "Please enter correct email"
            } else if passwordTmp.characters.count < MINIMAL_PASSWORD_LENTH {
                errorLabel.text = "Password must contain at leasst \(MINIMAL_PASSWORD_LENTH) symbols"
            } else if passwordRepeatTmp != passwordTmp {
                errorLabel.text = "Not the same password"
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
                request.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(request)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let emailField = result.value(forKey: "email") as? String {
                                if emailField == emailTmp {
                                    errorLabel.text = "User with the same email already exists"
                                    return false
                                }
                            }
                        }
                    }
                    
                    let newUser = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context)
                    
                    newUser.setValue(emailTmp, forKey: "email")
                    newUser.setValue(passwordTmp, forKey: "password")
                    
                    do {
                        
                        try context.save()
                        print("saved")
                        return true
                        
                    } catch {
                        errorLabel.text = "Error with Data Base"
                        return false
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMainScreen" {
            let mainController = segue.destination as! MainViewController
            mainController.userName = emailLabel.text!
        }
    }

}
