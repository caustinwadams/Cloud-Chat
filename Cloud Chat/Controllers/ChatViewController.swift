//
//  ViewController.swift
//  Flash Chat
//


import UIKit
import Firebase
import ChameleonFramework
import CoreData

// MARK: - Protocol for setting the last message for a conversation
protocol LastMessageDelegate {
    func setLastMessage(for user: String, message: Message)
    func clearNewMessages(for user: String)
}

class ChatViewController: UIViewController,
                          UITableViewDelegate,
                          UITableViewDataSource,
                          UITextFieldDelegate {
    
    // MARK: - Properties
    // Declare instance variables here
    var messageArray = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var recipient: String = ""
    let sender : String = (Auth.auth().currentUser?.email)!.components(separatedBy: "@")[0]
    var currentConversation: Conversation!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
    var lastMessageDelegate: LastMessageDelegate!
    
    var dbRef : DatabaseReference!
    

    
    // MARK: - Load Methods
    @objc
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = currentConversation.nickname!
        
        // Delegate and datasource here
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        self.messageTextfield.keyboardType = UIKeyboardType.default
        // Delegate of the text field here
        messageTextfield.delegate = self

         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
         messageTableView.addGestureRecognizer(tapGesture)

        // Registering the custom message cells
        messageTableView.register(UINib(nibName: "MessageCell",
                                        bundle: nil),
                                  forCellReuseIdentifier: "recievedMessageCell")
        messageTableView.register(UINib(nibName: "SentCell", bundle: nil),
                                  forCellReuseIdentifier: "sentMessageCell")
        
        configureTableView()
        
        loadCachedMessages()
        retrieveMessages()
        
        // Sort the messages by date
        messageArray.sort() {
            (message1, message2) in
            return message1.date! < message2.date!
        }
        
        messageTableView.separatorStyle = .none
        
        // set up the cusom notification functions
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: .UITextFieldTextDidChange, object: nil)
        sendButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !messageArray.isEmpty {
            let indexPath = IndexPath(row: messageArray.count - 1, section: 0)
            messageTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }
    

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods

    @objc
    func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let messageSender = messageArray[indexPath.row].sender
        
        if messageSender == sender {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sentMessageCell",
                                                     for: indexPath) as! SentMessageCell
            
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            //cell.senderUsername.text = messageArray[indexPath.row].sender == sender ? "Me" : recipient
            cell.avatarImageView.image = UIImage(named: "no-photo")
            
            cell.avatarImageView.layer.borderWidth = 1
            cell.avatarImageView.layer.masksToBounds = false
            cell.avatarImageView.layer.borderColor = UIColor.black.cgColor
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height/2
            cell.avatarImageView.clipsToBounds = true

            
//            if messageArray[indexPath.row].sender! == currentConversation.parentUser!.name! {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
//            } else {
//            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
//            cell.messageBackground.backgroundColor = UIColor.flatGray()
            //}
            cell.isUserInteractionEnabled = false
            return cell
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "recievedMessageCell",
                                                     for: indexPath) as! CustomMessageCell
            
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            //cell.senderUsername.text = messageArray[indexPath.row].sender == sender ? "Me" : recipient
            cell.avatarImageView.image = UIImage(named: "no-photo")
            
            cell.avatarImageView.layer.borderWidth = 1
            cell.avatarImageView.layer.masksToBounds = false
            cell.avatarImageView.layer.borderColor = UIColor.black.cgColor
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height/2
            cell.avatarImageView.clipsToBounds = true
            
//            if cell.senderUsername.text == "Me" {
            //cell.avatarImageView.backgroundColor = UIColor.flatMint()
            //cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            //} else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
           // }
            
            cell.isUserInteractionEnabled = false
        
        return cell
        }
    

       
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
   
    
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    
    
    //MARK: - Send & Recieve from Firebase

    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        print(dateString)
        
        let messageDB2 = Database.database().reference().child("Messages").child(recipient).child(self.sender)
        let messageDictionary = ["Sender" : self.sender,
                                 "Reciever" : recipient,
                                 "MessageBody" : messageTextfield.text!,
                                 "Time" : dateString]
        

        messageDB2.childByAutoId().setValue(messageDictionary) {
            (error2, reference2) in
            if error2 == nil {
                self.messageTextfield.text = ""
                
                let newMessage = Message(context: self.context)
                newMessage.sender = messageDictionary["Sender"]
                newMessage.reciever = messageDictionary["Reciever"]
                newMessage.messageBody = messageDictionary["MessageBody"]
                newMessage.date = messageDictionary["Time"]
                newMessage.parentConversation = self.currentConversation
                self.lastMessageDelegate.setLastMessage(for: newMessage.reciever!,
                                                        message: newMessage)
                self.messageArray.append(newMessage)
                self.saveMessages()
                self.viewWillAppear(true)
            } else {
                print(error2!)
            }
        }
                
                
        self.messageTextfield.isEnabled = true
        self.sendButton.isEnabled = false
        self.messageTextfield.text = ""
        
    }
    
    
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages").child(self.sender).child(recipient)
        messageDB.observe(.childAdded) {
            (snapshot) in
            
                print("Message added in CHATS")
                let snapshotValue = snapshot.value as! Dictionary<String, String>
                let text = snapshotValue["MessageBody"]!
                let curSender = snapshotValue["Sender"]!
                let time = snapshotValue["Time"]!
                //print("\(curSender) sent: \(text)")
                let message = Message(context: self.context)
                message.messageBody = text
                message.sender = curSender
                message.reciever = self.sender
                message.date = time
                message.parentConversation = self.currentConversation
                self.lastMessageDelegate.setLastMessage(for: message.sender!,
                                                        message: message)
                self.lastMessageDelegate.clearNewMessages(for: message.sender!)
                self.messageArray.append(message)
                self.saveMessages()


                messageDB.removeValue() {
                    (error, _) in
                    if error != nil {
                        print("Error: \(error!)")
                    }
                }

                self.configureTableView()

                self.messageTableView.reloadData()
            

        }
    }
    

    
    // MARK: - TextField / Keyboard Methods
    @objc
    func textChanged() {
        var enabled = false
        if !messageTextfield.text!.isEmpty {
            enabled = true
        }
        sendButton.isEnabled = enabled
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .init(rawValue: UInt(curve)), animations: { self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
            if !self.messageArray.isEmpty {
                self.viewWillAppear(true)
            }
        }, completion: nil)
        
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .init(rawValue: UInt(curve)), animations: { self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()}, completion: nil)
    }
    
    
    
    // MARK: - Saving / Loading from CoreData
    func saveMessages() {
        do {
            try context.save()
        } catch {
            print("Error saving messages: \(error)")
        }
        
        self.messageTableView.reloadData()
    }
    
    func loadCachedMessages(with request: NSFetchRequest<Message> = Message.fetchRequest(),
                      predicate: NSPredicate? = nil) {
        let predicateFormate = "parentConversation.user MATCHES %@ && parentConversation.parentUser.name MATCHES %@"
        let userPredicate = NSPredicate(format: predicateFormate,
                                        currentConversation!.user!,
                                        currentConversation!.parentUser!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate,
                                                                                    additionalPredicate])
        } else {
            request.predicate = userPredicate
        }
        do {
            messageArray = try context.fetch(request)
        } catch {
            print("Error loading conversations: \(error)")
        }
        
        self.messageTableView.reloadData()
    }
    
    
    

}



