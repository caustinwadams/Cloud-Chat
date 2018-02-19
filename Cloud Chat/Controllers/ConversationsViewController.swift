//
//  ConversationsViewController.swift
//  Flash Chat
//
//  Created by C. Austin Adams on 2/11/18.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ConversationsViewController: UITableViewController,
                                   AddConversationDelegate {
    
    // MARK: - Properties
    var conversations = [Conversation]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext


    
    // MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadConversations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return conversations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath)

        cell.textLabel?.text = conversations[indexPath.row].user

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toUser : String = conversations[indexPath.row].user!
        
        let recipient : String = toUser
        
        performSegue(withIdentifier: "goToChat", sender: recipient)
    }
    
    

    


    
    // MARK: - Navigation Methods

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "addConvo") {
            let controller = segue.destination as! AddConvoViewController
            controller.delegate = self
        }
        else if (segue.identifier == "goToChat") {
            let controller = segue.destination as! ChatViewController
            //print(sender as! String)
            controller.recipient = sender as! String
        }
        
    }
    
 
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch  {
            print("Error signing out")
        }
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "addConvo", sender: self)
        
    }
    
    
    
    // MARK: - Saving and Loading from CoreData
    
    func saveConversations() {
        do {
            try context.save()
        } catch {
            print("Error saving conversations: \(error)")
        }
    }
    
    
    func loadConversations(with request: NSFetchRequest<Conversation> = Conversation.fetchRequest()) {
        do {
            conversations = try context.fetch(request)
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    
    
    
    
    // MARK: - Conversation Delegate Method
    func addConvo(for user: String) {
        let convo = Conversation(context: self.context)
        convo.user = user
        conversations.append(convo)
        saveConversations()
        self.tableView.reloadData()
    }
    
}
