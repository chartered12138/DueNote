//
//  NoteCreateChangeViewController.swift
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//

import UIKit

class NoteCreateChangeViewController : UIViewController, UITextViewDelegate {

   

    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDoneButton: UIButton!
    @IBOutlet weak var DueDate: UIDatePicker!
    
    private(set) var changingNote : DueNote?

    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
        if self.changingNote != nil {
            // change mode
            noteDoneButton.isEnabled = true
        } else {
            // create mode
            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton, forEvent event: UIEvent) {
        // distinguish change mode and create mode
        if self.changingNote != nil {
            // change mode - change the item
            changeItem()
        } else {
            // create mode - create the item
            addItem()
        }
    }
    
    func setChangingNote(changingNote : DueNote) {
        self.changingNote = changingNote
    }
    
    private func addItem() -> Void {
        let note = DueNote(
            noteTitle:     noteTitleTextField.text!,
            noteText:      noteTextTextView.text,
            isSubmitted: false,
            dueDate: DueDate.date.toSeconds())

        NoteStorage.storage.addNote(noteToBeAdded: note)
        
        performSegue(
            withIdentifier: "backToMasterView",
            sender: self)
    }

    private func changeItem() -> Void {
        // get changed note instance
        if let changingNote = self.changingNote {
            // change the note through note storage
            NoteStorage.storage.changeNote(
                noteToBeChanged: DueNote(
                    noteId:        changingNote.noteId,
                    noteTitle:     noteTitleTextField.text!,
                    noteText:      noteTextTextView.text,
                    isSubmitted: changingNote.isSubmitted,
                    dueDate: DueDate.date.toSeconds()))
            
            // navigate back to list of notes
            performSegue(
                withIdentifier: "backToMasterView",
                sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set text view delegate so that we can react on text change
        noteTextTextView.delegate = self
        noteTextTextView.backgroundColor = UIColor.systemGray6
        noteTitleTextField.backgroundColor = UIColor.systemGray6
        view.backgroundColor = UIColor.systemGray6
        // check if we are in create mode or in change mode
        if let changingNote = self.changingNote {
            // in change mode: initialize for fields with data coming from note to be changed
            
            noteTextTextView.text = changingNote.noteText
            noteTitleTextField.text = changingNote.noteTitle
            DueDate.date = Date(seconds: changingNote.dueDate)
            // enable done button by default
            noteDoneButton.isEnabled = true
        } else {
            // in create mode: set initial time stamp label
//            noteDateLabel.text = NoteDateHelper.convertDate(date:DueDate.date)
        }
        
        // initialize text view UI - border width, radius and color
        noteTextTextView.layer.borderColor = CGColor(gray: 0.5, alpha: 0.3)
        noteTextTextView.layer.borderWidth = 1.0
        noteTextTextView.layer.cornerRadius = 15
        noteTitleTextField.layer.borderColor = CGColor(gray: 0.5, alpha: 0.3)
        noteTitleTextField.layer.borderWidth = 1.0
        noteTitleTextField.layer.cornerRadius = 15


        // For back button in navigation bar, change text
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }

    //Handle the text changes here
    func textViewDidChange(_ textView: UITextView) {
        if self.changingNote != nil {
            // change mode
            noteDoneButton.isEnabled = true
        } else {
            // create mode
            if ( noteTitleTextField.text?.isEmpty ?? true ) || ( textView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }

}
