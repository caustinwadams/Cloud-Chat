//
//  ConversationsViewController.swift
//  Cloud Chat
//
//  Created by C. Austin Adams on 2/11/18.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import CoreData


// MARK: - Conversation Cell Class
class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationCountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}



// MARK: - Conversation View Controller Class
class ConversationsViewController: UITableViewController,
                                   AddConversationDelegate {
    
    // MARK: - Properties
    
    var conversations = [Conversation]()
    var convosDictionary : [String : Conversation] = [:]
    var numNewMessages : [String : Int] = [:]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
    var loggedInUser: User!

    
    // MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("These are the conversations for \(loggedInUser.name!)")
        retrieveMessages()
        loadConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func findConversation(withName name: String) -> Conversation? {
//        for convo in conversations {
//            if convo.user == name {
//                return convo
//            }
//        }
//        return nil
//    }

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationCell

        let convo = conversations[indexPath.row]
        cell.textLabel?.text = convo.user
        cell.accessoryType = .disclosureIndicator
        let messageCount = numNewMessages[convo.user!]!
        print("\(convo.user!): \(messageCount)")
        if messageCount > 0 {
            print("Setting noti label")
            cell.notificationCountLabel.text = "\(messageCount)"
            cell.notificationView.backgroundColor = UIColor.blue
            cell.notificationView.layer.cornerRadius = cell.notificationView.frame.height / 2
            cell.notificationView.clipsToBounds = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toUser : String = conversations[indexPath.row].user!
        
        let recipient : String = toUser
        let convo = convosDictionary[recipient]
        
        performSegue(withIdentifier: "goToChat", sender: convo!)
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
            let convoToSend = sender as! Conversation
            controller.recipient = convoToSend.user!
            controller.currentConversation = convoToSend
            numNewMessages[convoToSend.user!] = 0
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
    
    
    func loadConversations(with request: NSFetchRequest<Conversation> = Conversation.fetchRequest(),
                           predicate: NSPredicate? = nil) {
        
        let userPredicate = NSPredicate(format: "parentUser.name MATCHES %@", loggedInUser!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate,
                                                                                    additionalPredicate])
        } else {
            request.predicate = userPredicate
        }
        do {
            conversations = try context.fetch(request)
            for convo in  conversations {
                convosDictionary[convo.user!] = convo
                numNewMessages[convo.user!] = 0
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
        
        tableView.reloadData()
    }
    

//    func loadConversations() {
//        conversations = parentUser.conversations
//    }
    
    
    
    // MARK: - Conversation Delegate Method
    func addConvo(for user: String) {
        let convo = Conversation(context: self.context)
        convo.user = user
        convo.parentUser = self.loggedInUser
        conversations.append(convo)
        convosDictionary[convo.user!] = convo
        numNewMessages[convo.user!] = 0
        saveConversations()
        self.tableView.reloadData()
    }
    
    
    
    
//    // MARK: - Core Data Functions
    // TODO: Retrieve messages here but dont delete them from Firebase until they are seen in the conversation
    func retrieveMessages() {

        let messageDB = Database.database().reference().child("Messages").child(loggedInUser.name!)
        messageDB.observe(.childAdded) {
            (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,Dictionary<String,String>>
            
            for key in snapshotValue.keys {
                let messageDict : [String:String] = snapshotValue[key]!
                let curSender = messageDict["Sender"]!

                if self.convosDictionary[curSender] == nil {
                    self.addConvo(for: curSender)
                }
                
                print("Messages for: \(curSender)")
                print("\(self.numNewMessages[curSender]!)")
                self.numNewMessages[curSender]! += 1
                print("\(self.numNewMessages[curSender]!)")
                
            }
            
//            //print("\(curSender) sent: \(text)")
//            let message = Message(context: self.context)
//            message.messageBody = text
//            message.sender = curSender
//            message.reciever = self.loggedInUser.name!
//            message.date = "\(Date())"
//            if let convo = self.convosDictionary[curSender] {
//                con
//            }
//
//            self.messageArray.append(message)
//            self.saveMessages()

            // Dont remove the messages from just the convos view.
            // Want to keep them until read so we have notifications
//            messageDB.removeValue() {
//                (error, _) in
//                if error != nil {
//                    print("Error: \(error!)")
//                }
//            }
//
//            self.configureTableView()
//
            self.tableView.reloadData()

        }
    }
    
}
