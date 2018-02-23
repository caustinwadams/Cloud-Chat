//
//  AddConvoViewController.swift
//  Cloud Chat
//

import UIKit



class AddConvoViewController: UIViewController {
    
    // MARK: - Properties
    var delegate: AddConversationDelegate!
    @IBOutlet weak var recipientTextField: UITextField!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        createButton.layer.cornerRadius = createButton.frame.height / 2
        createButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
        cancelButton.clipsToBounds = true
        
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
            let nickname = nicknameTextField.text!
            delegate.addConvo(for: userToAdd, nickname: nickname)
            self.dismiss(animated: true, completion: nil)
        }
     }
    
     
     @IBAction func cancelButtonPressed(_ sender: UIButton) {
     
     self.dismiss(animated: true, completion: nil)
     
     }

}

// MARK: - Delegate Definition
protocol AddConversationDelegate {
    
    func addConvo(for user: String, nickname: String)
    
}
