//
//  Message.swift
//  Flash Chat
//
//  This is the model class that represents the blueprint for a message

import Foundation

class Message {
    
    var reciever: String = ""
    var sender: String = ""
    var messageBody: String = ""
    var timeSent = Date()

}
