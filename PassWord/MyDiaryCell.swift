//
//  MyDiaryCell.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 25..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit

class MyDiaryCell: UITableViewCell {

    // 동적 테이블뷰를위한 custom cell - MyDiaryTableTableViewControll내의 한 셀이됨
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var WeatherImage: UIImageView!
    @IBOutlet weak var FaceImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
