//
//  ViewController.swift
//  Flash Chat
//


import UIKit
import Firebase
import ChameleonFramework
import CoreData


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
    
    var dbRef : DatabaseReference!
    
    // MARK: - Load Methods
    @objc
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = recipient
        //self.navigationItem.title = recipient[1]
        //print(recipient)
//        recipient[0] = String(describing: recipient[0].split(separator: "@", maxSplits: 1, omittingEmptySubsequences: true)[0])
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
         messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell",
                                        bundle: nil),
                                  forCellReuseIdentifier: "recievedMessageCell")
        messageTableView.register(UINib(nibName: "SentCell", bundle: nil),
                                  forCellReuseIdentifier: "sentMessageCell")
        
        configureTableView()
        
        loadCachedMessages()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    var i = 0
    
    
    @objc
    func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageSender = messageArray[indexPath.row].sender
    
        if messageSender == sender {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sentMessageCell",
                                                     for: indexPath) as! SentMessageCell
            
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender == sender ? "Me" : recipient
            cell.avatarImageView.image = UIImage(named: "egg")
            
            cell.avatarImageView.layer.borderWidth = 1
            cell.avatarImageView.layer.masksToBounds = false
            cell.avatarImageView.layer.borderColor = UIColor.black.cgColor
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height/2
            cell.avatarImageView.clipsToBounds = true

            
            if cell.senderUsername.text == "Me" {
                cell.avatarImageView.backgroundColor = UIColor.flatMint()
                cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            } else {
                cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
                cell.messageBackground.backgroundColor = UIColor.flatGray()
            }
            cell.isUserInteractionEnabled = false
            return cell
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "recievedMessageCell",
                                                     for: indexPath) as! CustomMessageCell
            
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender == sender ? "Me" : recipient
            cell.avatarImageView.image = UIImage(named: "egg")
            
            cell.avatarImageView.layer.borderWidth = 1
            cell.avatarImageView.layer.masksToBounds = false
            cell.avatarImageView.layer.borderColor = UIColor.black.cgColor
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height/2
            cell.avatarImageView.clipsToBounds = true
            
            if cell.senderUsername.text == "Me" {
                cell.avatarImageView.backgroundColor = UIColor.flatMint()
                cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            } else {
                cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
                cell.messageBackground.backgroundColor = UIColor.flatGray()
            }
            
            cell.isUserInteractionEnabled = false
        
        return cell
        }
    

       
    }
    
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
   
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
//
//
//
//        let duration = aNotification.userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey) as NSNumber
//        let curve = aNotification.userInfo.objectForKey(UIKeyboardAnimationCurveUserInfoKey) as NSNumber
        //let duration = UIKeyboardAnimationDurationUserInfoKey as! Double
        //let curve = UserInfo.UIKeyboardAnimationCurveUserInfoKey
        
        
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.3) {
//            self.heightConstraint.constant = 50
//            self.view.layoutIfNeeded()
//        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase

    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        //let messageDB = Database.database().reference().child("Messages").child(self.sender).child(recipient)
        let messageDB2 = Database.database().reference().child("Messages").child(recipient).child(self.sender)
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        print("Current Time: \(hour):\(minutes)")
        let messageDictionary = ["Sender" : self.sender,
                                 "Reciever" : recipient,
                                 "MessageBody" : messageTextfield.text!,
                                 "Time" : "\(Date())"]
        

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
                self.messageArray.append(newMessage)
                self.saveMessages()
                
            } else {
                print(error2!)
            }
        }
                
                
        self.messageTextfield.isEnabled = true
        self.sendButton.isEnabled = true
        self.messageTextfield.text = ""

        
    }
    
    
    func retrieveMessages() {

        let messageDB = Database.database().reference().child("Messages").child(self.sender).child(recipient)
        messageDB.observe(.childAdded) {
            (snapshot) in
                    let snapshotValue = snapshot.value as! Dictionary<String, String>
                    let text = snapshotValue["MessageBody"]!
                    let curSender = snapshotValue["Sender"]!
                    //print("\(curSender) sent: \(text)")
                    let message = Message(context: self.context)
                    message.messageBody = text
                    message.sender = curSender
                    message.reciever = self.sender
                    message.date = "\(Date())"
                    message.parentConversation = self.currentConversation

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
    
    
    // MARK: - TextField / Keyboard Animation Methods
    @objc func keyboardWillShow(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .init(rawValue: UInt(curve)), animations: { self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()}, completion: nil)
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

