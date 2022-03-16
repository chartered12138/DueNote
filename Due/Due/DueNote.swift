//
//  File.swift
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//

import Foundation

class DueNote {
    
    private(set) var noteId        : UUID
    private(set) var noteTitle     : String
    private(set) var noteText      : String
    private(set) var isSubmitted : Bool
    private(set) var dueDate : Int64
    
    init(noteTitle:String, noteText:String, isSubmitted:Bool, dueDate:Int64) {
        self.noteId        = UUID()
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.isSubmitted = isSubmitted
        self.dueDate = dueDate
    }

    init(noteId: UUID, noteTitle:String, noteText:String, isSubmitted:Bool, dueDate:Int64) {
        self.noteId        = noteId
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.isSubmitted = isSubmitted
        self.dueDate = dueDate
    }
}
