//
//  NoteCreateChangeViewController.swift
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//

import UIKit

class NoteCreateChangeViewController : UIViewController, UITextViewDelegate {
    
    let defaultGrayScale = UserDefaults.standard.integer(forKey: "gray_scale")
   
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
    
    
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDoneButton: UIButton!
    @IBOutlet weak var DueDate: UIDatePicker!
    // go back to master page if click on checkmark icon
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMasterView" {
            let vc = segue.destination as! UINavigationController
            vc.modalPresentationStyle = .fullScreen
            
        }
    }
    private(set) var changingNote : DueNote?
    // manage changing state of create state
    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
        if self.changingNote != nil {
            noteDoneButton.isEnabled = true
        } else {
            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }
    // change note or create note
    @IBAction func doneButtonClicked(_ sender: UIButton, forEvent event: UIEvent) {
       
        if self.changingNote != nil {
            changeItem()
        } else {
            // create mode - create the item
            addItem()
        }
    }
    
    func setChangingNote(changingNote : DueNote) {
        self.changingNote = changingNote
    }
    // add task
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
    // change task
    private func changeItem() -> Void {
        if let changingNote = self.changingNote {
            NoteStorage.storage.changeNote(
                noteToBeChanged: DueNote(
                    noteId:        changingNote.noteId,
                    noteTitle:     noteTitleTextField.text!,
                    noteText:      noteTextTextView.text,
                    isSubmitted: changingNote.isSubmitted,
                    dueDate: DueDate.date.toSeconds()))
            
            performSegue(
                withIdentifier: "backToMasterView",
                sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTextTextView.isScrollEnabled = true
        noteTextTextView.text = "Description"
        noteTextTextView.textColor = UIColor.lightGray
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        noteTextTextView.delegate = self
        noteTextTextView.backgroundColor = defaultBackGroundGray(grayScale: defaultGrayScale)
        noteTitleTextField.backgroundColor = defaultBackGroundGray(grayScale: defaultGrayScale)
        view.backgroundColor = defaultBackGroundGray(grayScale: defaultGrayScale)
        // fill existing data in the page
        if let changingNote = self.changingNote {
            noteTextTextView.text = changingNote.noteText
            noteTitleTextField.text = changingNote.noteTitle
            DueDate.date = Date(seconds: changingNote.dueDate)
            noteDoneButton.isEnabled = true
        }
   
        
        // For back button in navigation bar, change text
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteTextTextView.textColor = UIColor.label
    }
    // if text area is empty, given default "Description"
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextTextView.text == "" {
            noteTextTextView.text = "Description"
            noteTextTextView.textColor = UIColor.systemGray2
        }
    }
    //Handle done button enable for changing mode and creating mode
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
