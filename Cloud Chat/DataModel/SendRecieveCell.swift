//
//  SendRecieveCell.swift
//  Cloud Chat
//
//  Created by C. Austin Adams on 2/14/18.
//

import UIKit

class SendRecieveCell: UITableViewCell {

    @IBOutlet weak var msgBackground = UIView()
    @IBOutlet weak var msgImageView = UIImageView()
    @IBOutlet weak var msgUsername = UILabel()
    @IBOutlet weak var msgBody = UILabel()
    var color : UIColor = UIColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
