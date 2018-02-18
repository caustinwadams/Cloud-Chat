//
//  RegisterViewController.swift
//  Flash Chat
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
    
    
    //MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK: - Button Methods
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        //TODO: Set up a new user on our Firbase database
        Auth.auth().createUser(withEmail: emailTextfield.text!,
                               password: passwordTextfield.text!) {
            (user, error) in
                                
            if error != nil {
                print(error!)
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
