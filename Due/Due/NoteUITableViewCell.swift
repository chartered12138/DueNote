//
//  
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//

import UIKit

import UIKit

class NoteUITableViewCell : UITableViewCell {
    private(set) var title : String = ""
    private(set) var timeRemaining  : String = ""
    private(set) var dueDate  : String = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    

        
    
}
