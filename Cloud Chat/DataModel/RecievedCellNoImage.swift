//
//  RecievedCellNoImage.swift
//  Cloud Chat
//
//  Created by C. Austin Adams on 3/4/18.
//  Copyright © 2018 Austin Adams. All rights reserved.
//

import UIKit

class RecievedCellNoImage: SendRecieveCell {

    @IBOutlet weak var messageBackground: UIView!
    
    @IBOutlet weak var messageBody: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.msgBackground = messageBackground
        self.msgBody = messageBody
        self.color = UIColor.flatGray()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
