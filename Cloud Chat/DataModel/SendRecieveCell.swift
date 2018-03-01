//
//  SendRecieveCell.swift
//  Cloud Chat
//
//  Created by C. Austin Adams on 2/14/18.
//

import UIKit

class SendRecieveCell: UITableViewCell {

    weak var msgBackground: UIView!
    weak var msgImageView: UIImageView!
    weak var msgUsername: UILabel!
    weak var msgBody: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
