//
//  MeansOfPaymentTableViewCell.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 02/05/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit

class MeansOfPaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var documentLabel: UILabel!
    @IBOutlet weak var validateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberView.layer.cornerRadius = 5.0
        numberView.layer.masksToBounds = false
        detailsView.layer.cornerRadius = 5.0
        detailsView.layer.masksToBounds = false
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCard(_ card: Card) {
        numberLabel.text = card.number.applyPatternOnNumbers(pattern: "####.####.####.####", replacmentCharacter: "#")
        nameLabel.text = card.name.uppercased()
        documentLabel.text = card.document.applyPatternOnNumbers(pattern: "###.###.###-##", replacmentCharacter: "#")
        validateLabel.text = "\(card.monthValidate)/\(card.yearValidate)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = ""
        nameLabel.text = ""
        documentLabel.text = ""
        validateLabel.text = ""
    }
}
