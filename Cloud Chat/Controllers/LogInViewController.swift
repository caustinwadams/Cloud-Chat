//
//  LogInViewController.swift
//  Cloud Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD
import CoreData


class LogInViewController: UIViewController {

    // MARK: - Properties
    //TextFields pre-linked with IBOutlets
    @IBOutlet var userTextField: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
    var username : String = ""
    var knownUsers = [User]()
    
    //MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        errorLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func findUser(withName name: String) -> User? {
        for user in knownUsers {
            if user.name == name {
                return user
            }
        }
        return nil
    }
    
    

   
    //MARK: - Navigation
    @IBAction func logInPressed(_ sender: AnyObject) {
        errorLabel.text = ""

        username = userTextField.text!
        if username == "" {
            self.errorLabel.text = "MUST ENTER USERNAME"
        } else if passwordTextfield.text! == "" {
            self.errorLabel.text = "MUST ENTER PASSWORD"
        } else {
            SVProgressHUD.show()
            let userEmail = username + "@email.com"
            
            Auth.auth().signIn(withEmail: userEmail,
                               password: passwordTextfield.text!)
            {
                (user, error) in
                if error == nil {
                    print("Login Successful.")
                    
                    // Try to find user in our list of known users,
                    // if not found, we create a new one and save it to the context
                    var senderUser = self.findUser(withName: self.username)
                    if senderUser == nil {
                        senderUser = User(context: self.context)
                        senderUser?.name = self.username.lowercased()
                        self.saveUsers()
                    }
                    
                    self.performSegue(withIdentifier: "goToConversations", sender: senderUser!)
                } else {
                    let noUserError = "There is no user record corresponding to this identifier. The user may have been deleted."
                    let wrongPasswordError = "The password is invalid or the user does not have a password."
                    let realError = error!.localizedDescription
                    
                    
                    if realError == noUserError {
                        self.errorLabel.text = "NO USER BY THAT NAME"
                        self.userTextField.shake()
                    } else if realError == wrongPasswordError {
                        self.errorLabel.text = "WRONG PASSWORD"
                        self.passwordTextfield.shake()
                    }
                    
                }
                
                SVProgressHUD.dismiss()
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToConversations" {
            let destination = segue.destination as! ConversationsViewController
            destination.loggedInUser = sender as! User
        }
    }
    
    
    
    // MARK: - Core Data Methods
    func saveUsers() {
        do {
            try context.save()
        } catch {
            print("Error saving users: \(error)")
        }
    }
    
    func loadUsers(with request: NSFetchRequest<User> = User.fetchRequest()) {
        do {
            knownUsers = try context.fetch(request)
        } catch {
            print("Error loading users: \(error)")
        }
    }

    
}


// MARK: - Shake animation for username / passowrd errors
public extension UIView {
    
    func shake(count : Float = 4,for duration : TimeInterval = 0.5,withTranslation translation : Float = -5) {
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation
        layer.add(animation, forKey: "shake")
    }
}
