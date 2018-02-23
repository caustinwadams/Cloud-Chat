//
//  ConversationsCell.swift
//  Cloud Chat
//
//  Created by C. Austin Adams on 2/22/18.
//  Copyright © 2018 Austin Adams. All rights reserved.
//

import UIKit

class ConversationsCell: UITableViewCell {

    @IBOutlet weak var numMessagesLabel: UILabel!
    @IBOutlet weak var convoImageView: UIImageView!
    @IBOutlet weak var convoTimeLabel: UILabel!
    @IBOutlet weak var conversationUserLabel: UILabel!
    
    @IBOutlet weak var convoNotificationView: UIView!
    @IBOutlet weak var convoMessageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
