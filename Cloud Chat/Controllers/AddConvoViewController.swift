//
//  AddConvoViewController.swift
//  Flash Chat
//
//  Created by C. Austin Adams on 2/11/18.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit



class AddConvoViewController: UIViewController {
    
    // MARK: - Properties
    var delegate: AddConversationDelegate!
    @IBOutlet weak var recipientTextField: UITextField!
    
    

    
    // MARK: - Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
     
     @IBAction func createButtonPressed(_ sender: UIButton) {
     
        // Fill in later (after delegate creation)
        if recipientTextField.text! != "" {
            let userToAdd = recipientTextField.text!
            delegate.addConvo(for: userToAdd)
            self.dismiss(animated: true, completion: nil)
        }
     }
    
     
     @IBAction func cancelButtonPressed(_ sender: UIButton) {
     
     self.dismiss(animated: true, completion: nil)
     
     }

}

// MARK: - Delegate Definition
protocol AddConversationDelegate {
    
    func addConvo(for user: String)
    
}
