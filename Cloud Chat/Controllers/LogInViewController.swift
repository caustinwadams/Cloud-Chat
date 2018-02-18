//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD


class LogInViewController: UIViewController {

    // MARK: - Properties
    //TextFields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    //MARK: - Login Methods
    @IBAction func logInPressed(_ sender: AnyObject) {

        SVProgressHUD.show()
        
        //TODO: Log in the user
        let userName = emailTextfield.text! + "@email.com"
        
        Auth.auth().signIn(withEmail: userName,
                           password: passwordTextfield.text!)
        {
            (user, error) in
            if error == nil {
                print("Login Successful.")
                
                
                
                self.performSegue(withIdentifier: "goToConversations", sender: self)
            } else {
                print("Login failed...")
            }
            
            SVProgressHUD.dismiss()
        }
        
        
    }
    


    
}  
