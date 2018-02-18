//
//  SendRecieveCell.swift
//  Flash Chat
//
//  Created by C. Austin Adams on 2/14/18.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit

class SendRecieveCell: UITableViewCell {

    weak var messageBackground: UIView!
    weak var avatarImageView: UIImageView!
    weak var senderUsername: UILabel!
    weak var messageBody: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
