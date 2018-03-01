//
//  SentMessageCell.swift
//  Flash Chat
//
//  Created by C. Austin Adams on 2/14/18.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit

class SentMessageCell: SendRecieveCell {

    
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var senderUsername: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
