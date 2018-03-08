//
//  RegisterViewController.swift
//  Cloud Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD


class RegisterViewController: UIViewController {

    //MARK: - Properties
    //Pre-linked IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    //MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = registerButton.frame.height / 2
        errorLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK: - Button Methods
    @IBAction func registerPressed(_ sender: AnyObject) {
        errorLabel.text = ""
        SVProgressHUD.show()
        
        //TODO: Set up a new user on our Firbase database
        Auth.auth().createUser(withEmail: emailTextfield.text! + "@email.com",
                               password: passwordTextfield.text!) {
            (user, error) in
                                
            if error != nil {
                let curError = error!.localizedDescription
                let userExists =
                    "The email address is already in use by another account."
                let badUserFormat = "The email address is badly formatted."
                let passwordError = "The password must be 6 characters long or more."
                if curError == userExists ||
                    curError == badUserFormat {
                    self.errorLabel.text =
                        curError == userExists ?
                        "USER ALREADY EXISTS" :
                        "USERNAME CANNOT CONTAIN (. , @)"
                    self.emailTextfield.shake()
                } else if curError == passwordError {
                    self.errorLabel.text = "PASSWORD MUST BE AT LEAST 6 CHARACTERS"
                    self.passwordTextfield.shake()
                }
            } else {
                print("Registration Successful!")
                self.emailTextfield.text! = ""
                self.passwordTextfield.text! = ""
                
                self.performSegue(withIdentifier: "goToConversations", sender: self)
            }
                                
            SVProgressHUD.dismiss()
                                
        }
        

        
        
    } 
    
    
}
