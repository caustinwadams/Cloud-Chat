//
//  ConversationsViewController.swift
//  Cloud Chat
//
//  Created by C. Austin Adams on 2/11/18.
//

import UIKit
import Firebase
import CoreData


// MARK: - Conversation View Controller Class
class ConversationsViewController: UITableViewController {
    
    // MARK: - Properties
    
    var conversations = [Conversation]()
    var convosDictionary : [String : Conversation] = [:]
    var nicknamesDictionary : [String : String] = [:]
    var numNewMessages : [String : Int] = [:]
    var lastMessageDictionary : [String : Message] = [:]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
    var loggedInUser: User!
    var userInChat : Bool = false

    
    // MARK: - On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registering the custom conversation cell
        tableView.register(UINib(nibName: "ConversationsCell",
                                        bundle: nil),
                                  forCellReuseIdentifier: "convoCell")
        print("These are the conversations for \(loggedInUser.name!)")
        retrieveMessages()
        loadConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userInChat = false
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
        setLabels(for: cell, at: indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toUser : String = conversations[indexPath.row].user!
        
        let recipient : String = toUser
        let convo = convosDictionary[recipient]
        userInChat = true
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
            controller.lastMessageDelegate = self
            controller.recipient = convoToSend.user!
            controller.currentConversation = convoToSend
            numNewMessages[convoToSend.user!] = 0
            convoToSend.numNewMessages = 0
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
    
    
    // MARK: - Helper Methods
    // Setting the labels in the paramter tableViewCell
    func setLabels(for tableCell: ConversationsCell, at row: Int) {
        
        let convo = conversations[row]
        tableCell.conversationUserLabel.text! = nicknamesDictionary[convo.user!]!
        tableCell.conversationUserLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        // Setting the label for the last message
        if let lastMessage = convo.lastMessage {
//            print(lastMessage.date!)
//            print("CONVERTED TO: \(stringToDate(for: lastMessage.date!))")
            var timeString = lastMessage.date!.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
            let timeArr = timeString[1].split(separator: ":", maxSplits: 2, omittingEmptySubsequences: true)
            var timeInt = Int(timeArr[0])!
            if timeInt >= 12 {
                if timeInt > 12 {
                    timeInt -= 12
                }
                timeString.append("PM")
            } else {
                if timeInt == 0 {
                    timeInt = 12
                }
                if timeString.count < 3 {
                    timeString.append("AM")
                }
            }
            
            let realTime = "\(timeInt):\(timeArr[1]) \(timeString[2])"
            tableCell.convoTimeLabel.text = realTime
            print(realTime)
            
            //print(timeString)
            let body = lastMessage.messageBody!
            tableCell.convoMessageLabel.text! = body
        } else {
            tableCell.convoMessageLabel.text! = "(No Messages)"
            tableCell.convoTimeLabel.text = "--:--"
        }
        
        let imageView = tableCell.convoImageView!
        imageView.image = UIImage(named:"no-photo")
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        
        //        let messageCount = numNewMessages[convo.user!]!
        // Show notitfication if conversation has new messages
        let messageCount = convo.numNewMessages
        if messageCount > 0 {
            let notiView = tableCell.convoNotificationView!
            tableCell.numMessagesLabel.text! = "\(messageCount)"
            notiView.isHidden = false
            notiView.backgroundColor = UIColor.blue
            notiView.layer.cornerRadius = notiView.frame.height / 2
        } else {
            tableCell.convoNotificationView.isHidden = true
        }
    }
    
    
    func stringToDate(for str: String) -> Date {
        print(str)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: str)
        return date!
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
                nicknamesDictionary[convo.user!] = convo.nickname!
                lastMessageDictionary[convo.user!] = convo.lastMessage
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
    
    
    

    

    
    
    
    
//    // MARK: - Core Data Functions
    // TODO: Set the newest message for each conversation to a dictionary variable.
    // Then we can display time and text of last message in each convo cell
    func retrieveMessages() {

        let messageDB = Database.database().reference().child("Messages").child(loggedInUser.name!)
        messageDB.observe(.childAdded) {
            (snapshot) in
            if !self.userInChat {
                print("Message Added in Convos")
                let snapshotValue = snapshot.value as! Dictionary<String,Dictionary<String,String>>
                
                for key in snapshotValue.keys {
                    let messageDict : [String:String] = snapshotValue[key]!
                    let curSender = messageDict["Sender"]!
                    let text = messageDict["MessageBody"]!
                    let time = messageDict["Time"]!
                    if self.convosDictionary[curSender] == nil {
                        self.addConvo(for: curSender, nickname: curSender)
                    }
                    
                    let message = Message(context: self.context)
                    message.messageBody = text
                    message.sender = curSender
                    message.reciever = self.loggedInUser.name!
                    message.parentConversation = self.convosDictionary[curSender]!
                    message.date = time
                    
                    messageDB.removeValue() {
                        (error, _) in
                        if error != nil {
                            print("Error: \(error!)")
                        }
                    }
                    
                    self.setLastMessage(for: curSender, message: message)
                    self.convosDictionary[curSender]!.numNewMessages += 1
                    
                    print("Messages for: \(curSender)")
                    print("\(self.numNewMessages[curSender]!)")
                    self.numNewMessages[curSender]! += 1
                    print("\(self.numNewMessages[curSender]!)")
                    
                }
                self.tableView.reloadData()
            }

        }
    }
    
}

// MARK: - Last Message Delegate Definitions
extension ConversationsViewController: LastMessageDelegate {
    func setLastMessage(for user: String, message: Message) {
        convosDictionary[user]!.lastMessage = message
        
        print("\(convosDictionary[user]!.lastMessage!.messageBody!)")
        saveConversations()
        tableView.reloadData()
    }
    
    
    func clearNewMessages(for user: String) {
        convosDictionary[user]!.numNewMessages = 0
        saveConversations()
    }
}


// MARK: - Add Conversation Delegate Definitions
extension ConversationsViewController: AddConversationDelegate {
    // MARK: - Conversation Delegate Method
    func addConvo(for user: String, nickname: String) {
        let convo = Conversation(context: self.context)
        convo.user = user
        convo.nickname = nickname
        convo.parentUser = self.loggedInUser
        conversations.append(convo)
        convosDictionary[convo.user!] = convo
        nicknamesDictionary[user] = nickname
        numNewMessages[convo.user!] = 0
        convo.numNewMessages = 0
        saveConversations()
        self.tableView.reloadData()
    }
}
