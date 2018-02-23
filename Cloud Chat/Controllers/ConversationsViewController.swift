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
        
        
        tableView.register(UINib(nibName: "ConversationsCell",
                                        bundle: nil),
                                  forCellReuseIdentifier: "convoCell")
        
        
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return conversations.count
    }

    // Sets up the ConversationsCell with the correct information
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath) as! ConversationsCell
        let convo = conversations[indexPath.row]
        cell.conversationUserLabel.text! = convo.user!
        
        
        let imageView = cell.convoImageView!
        imageView.image = UIImage(named:"no-photo")
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        
        let messageCount = numNewMessages[convo.user!]!
        // Show notitfication if conversation has new messages
        if messageCount > 0 {
            cell.conversationUserLabel.font = UIFont.boldSystemFont(ofSize: 16)
            let notiView = cell.convoNotificationView!
            cell.numMessagesLabel.text! = "\(messageCount)"
            notiView.isHidden = false
            notiView.backgroundColor = UIColor.blue
            notiView.layer.cornerRadius = notiView.frame.height / 2
            
        } else {
            cell.convoNotificationView.isHidden = true
            cell.conversationUserLabel.font = UIFont.systemFont(ofSize: 16)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toUser : String = conversations[indexPath.row].user!
        
        let recipient : String = toUser
        let convo = convosDictionary[recipient]
        
        performSegue(withIdentifier: "goToChat", sender: (convo!, indexPath))
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
            let (convoToSend, _) = sender as! (Conversation, IndexPath)
            // TODO: This may need to change because it may affect many cells
            //let cell = tableView(self.tableView, cellForRowAt: path) as! ConversationsCell
            //cell.conversationUserLabel.font = UIFont.systemFont(ofSize: 16)
//            print("\(cell.textLabel!.text!)")
            //cell.notificationView.alpha = 0.0
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
    // TODO: Set the newest message for each conversation to a dictionary variable.
    // Then we can display time and text of last message in each convo cell
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
