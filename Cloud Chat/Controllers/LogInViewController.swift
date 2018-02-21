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
    
    @IBOutlet weak var loginButton: UIButton!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
    var username : String = ""
    var knownUsers = [User]()
    
    //MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
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

        SVProgressHUD.show()
        
        username = userTextField.text!
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
                print("Login failed...")
            }
            
            SVProgressHUD.dismiss()
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
