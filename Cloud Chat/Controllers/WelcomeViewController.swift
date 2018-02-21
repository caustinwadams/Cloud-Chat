//
//  WelcomeViewController.swift
//  Cloud Chat
//
//  This is the welcome view controller - the first thign the user sees
//

import UIKit



class WelcomeViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var cloud1: UIImageView!
    @IBOutlet weak var cloud2: UIImageView!
    
    // TODO: Fix these constraints to do animations
    @IBOutlet weak var cloud2Const: NSLayoutConstraint!
    @IBOutlet weak var cloud1Const: NSLayoutConstraint!
    
    @IBAction func showLogin(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowLogin", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = registerButton.frame.height / 2
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        
        cloud1.image = UIImage(named: "cloud")
        cloud2.image = UIImage(named: "cloud")
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
