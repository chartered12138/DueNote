//
//  DetailViewController.swift
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//

import UIKit

class DetailViewController: UIViewController {
    let defaultGrayScale = UserDefaults.standard.integer(forKey: "gray_scale")
   // read gray scale background color from settings, default gray6
    func defaultBackGroundGray(grayScale: Int)->UIColor{
        if (grayScale == 1){
            return .systemGray
        }else if (grayScale == 2){
            return .systemGray2
        }else if (grayScale == 3){
            return .systemGray3
        }else if (grayScale == 4){
            return .systemGray4
        }else if (grayScale == 5){
            return .systemGray5
        }else{
            return .systemGray6
        }
    }
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDate: UILabel!
    @IBOutlet weak var timeRemaining: UILabel!
    var timer = Timer()
    // given seconds difference, return a string displayed on screen
    func timeRemainingToStr(isSubmitted:Bool,secondsDifference: Int64) -> String{
        if (isSubmitted){
            return "Submitted!"
        }
        if(secondsDifference<=0){
            return "Past due"
        }else if (secondsDifference<3600){
            return String(secondsDifference/60) + " minutes "+String(secondsDifference%60)+" seconds left"
        }else if (secondsDifference<86400){
            return String(secondsDifference/3600) + " hours "+String((secondsDifference%3600)/60)+" minutes left"
        }else{
            return String(secondsDifference/86400) + " days "+String((secondsDifference%86400)/3600)+" hours left"
        }
    }
    
    @objc func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let topicLabel = noteTitleLabel,
               let dateLabel = noteDate,
               let textView = noteTextTextView,
               let time = timeRemaining{
                topicLabel.text = detail.noteTitle
                dateLabel.text = NoteDateHelper.convertDate(date: Date.init(seconds: detail.dueDate))
                textView.text = detail.noteText
                time.text = timeRemainingToStr(isSubmitted:detail.isSubmitted,secondsDifference: detail.dueDate-Date().toSeconds())
                if (detail.isSubmitted){
                    time.textColor = .systemGreen
                }else{
                    if(detail.dueDate-Date().toSeconds()<=0){
                        time.textColor = .systemRed
                    }else if(detail.dueDate-Date().toSeconds()<=10800){
                        time.textColor = .systemOrange
                    }else{
                        time.textColor = .label
                    }
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = defaultBackGroundGray(grayScale: defaultGrayScale)
        noteTextTextView.backgroundColor = defaultBackGroundGray(grayScale: defaultGrayScale)
        configureView()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(configureView), userInfo: nil, repeats: true);
    }
    
    var detailItem: DueNote? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // segue that to chagne the due
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChangeNoteSegue" {
            let changeNoteViewController = segue.destination as! NoteCreateChangeViewController
            if let detail = detailItem {
                changeNoteViewController.setChangingNote(
                    changingNote: detail)
            }
        }
    }
}

