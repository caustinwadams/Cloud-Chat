//
//  ViewController.swift
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
        messageTableView.register(UINib(nibName: "SentCell",
                                        bundle: nil),
                                  forCellReuseIdentifier: "sentMessageCell")
        messageTableView.register(UINib(nibName: "SentCellNoImage",
                                        bundle: nil),
                                  forCellReuseIdentifier: "sentCellNoImage")
        
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
        setSendButton(isEnabled: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !messageArray.isEmpty {
            let indexPath = IndexPath(row: messageArray.count - 1, section: 0)
            messageTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }
    


    //////////////////////////////////////
    //MARK: - TableView DataSource Methods

    @objc
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let messageSender = messageArray[row].sender
        var reuseIdentifier: String
        if messageSender == sender {
            if (row == messageArray.count - 1 ||
               messageArray[row + 1].sender! != sender) {
                reuseIdentifier = "sentMessageCell"
            } else {
                reuseIdentifier = "sentCellNoImage"
            }
        } else {
            reuseIdentifier = "recievedMessageCell"
        }
        return createCell(for: tableView, at: indexPath, withIdentifier: reuseIdentifier)
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
    
    // Helper method for cellForRowAt method.
    // Creates a new cell with the given reuseIdentifier
    func createCell(for tableView: UITableView,
                    at indexPath: IndexPath,
                    withIdentifier reuseIdentifier: String) -> SendRecieveCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! SendRecieveCell
        
        var hasImage = false

        switch (reuseIdentifier) {
        case "sentMessageCell":
            hasImage = true
            cell = cell as! SentMessageCell
            break
        case "recievedMessageCell":
            hasImage = true
            cell = cell as! CustomMessageCell
            break
        case "sentCellNoImage":
            cell = cell as! SentCellNoImage
            break
        default:
            break
        }
        
        if hasImage {
            cell.msgImageView!.image = UIImage(named: "no-photo")
            cell.msgImageView!.layer.borderWidth = 1
            cell.msgImageView!.layer.masksToBounds = false
            cell.msgImageView!.layer.borderColor = UIColor.black.cgColor
            cell.msgImageView!.layer.cornerRadius = cell.msgImageView!.frame.height/2
            cell.msgImageView!.clipsToBounds = true
        }
        
        cell.msgBody!.text = messageArray[indexPath.row].messageBody
        cell.msgBackground!.backgroundColor = cell.color
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    
    // MARK: - TextField / Keyboard Methods
    @objc
    func textChanged() {
        var enabled = false
        if !messageTextfield.text!.isEmpty {
            enabled = true
        }
        setSendButton(isEnabled: enabled)
    }
    
    
    func setSendButton(isEnabled: Bool) {
        var textColor = UIColor.lightGray
        var bgColor = UIColor.flatBlueColorDark()
        sendButton.isEnabled = isEnabled
        if sendButton.isEnabled {
            textColor = UIColor.white
            bgColor = UIColor.flatSkyBlue()
        }
        sendButton.setTitleColor(textColor, for: .normal)
        sendButton.backgroundColor = bgColor
    }
    
    // Method to animate the text field upwards when the keyboard appears
    @objc func keyboardWillShow(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: .init(rawValue: UInt(curve)),
                       animations: { self.heightConstraint.constant = 308
                            self.view.layoutIfNeeded()
                            if !self.messageArray.isEmpty {
                                self.viewWillAppear(true)
                            }
                       },
                       completion: nil)
        
    }
    
    // Method to move the textfield down when the keyboard disappears
    @objc func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: .init(rawValue: UInt(curve)),
                       animations: {
                         self.heightConstraint.constant = 50
                         self.view.layoutIfNeeded()
                       },
                       completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.send &&
           !textField.text!.isEmpty {
            sendPressed(self)
        }
        return true
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
        
        let messageDB = Database.database().reference().child("Messages").child(recipient).child(self.sender)
        let messageDictionary = ["Sender"      : self.sender,
                                 "Reciever"    : recipient,
                                 "MessageBody" : messageTextfield.text!,
                                 "Time"        : dateString]
        
        
        messageDB.childByAutoId().setValue(messageDictionary) {
            (error2, reference2) in
            if error2 == nil {
                self.messageTextfield.text = ""
                self.createNewMessage(msgText     : messageDictionary["MessageBody"]!,
                                      msgSender   : messageDictionary["Sender"]!,
                                      msgReciever : messageDictionary["Reciever"]!,
                                      msgTime     : messageDictionary["Time"]!,
                                      recieving   : false)
                self.viewWillAppear(true)
            } else {
                print(error2!)
            }
        }
        
        self.messageTextfield.isEnabled = true
        self.setSendButton(isEnabled: false)
        self.messageTextfield.text = ""
    }
    
    
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages").child(self.sender).child(recipient)
        messageDB.observe(.childAdded) {
            (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let text = snapshotValue["MessageBody"]!
            let curSender = snapshotValue["Sender"]!
            let time = snapshotValue["Time"]!
            
            self.createNewMessage(msgText     : text,
                                  msgSender   : curSender,
                                  msgReciever : self.sender,
                                  msgTime     : time,
                                  recieving   : true)
            
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
    
    // Creates a new Message instance and saves it to the context
    func createNewMessage(msgText    : String,
                          msgSender  : String,
                          msgReciever: String,
                          msgTime    : String,
                          recieving  : Bool) {
        let message = Message(context: self.context)
        message.messageBody = msgText
        message.sender = msgSender
        message.reciever = msgReciever
        message.date = msgTime
        message.parentConversation = self.currentConversation
        let lastMessageUser = recieving ? message.sender! : message.reciever!
        self.lastMessageDelegate.setLastMessage(for: lastMessageUser,
                                                message: message)
        self.lastMessageDelegate.clearNewMessages(for: lastMessageUser)
        self.messageArray.append(message)
        self.saveMessages()
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
            request.predicate =
                NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate,
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
