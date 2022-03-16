//
//  NoteStorage.swift
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//


import CoreData

class NoteStorage {
    static let storage : NoteStorage = NoteStorage()
    
    private var noteIndexToIdDict : [Int:UUID] = [:]
    private var currentIndex : Int = 0

    private(set) var managedObjectContext : NSManagedObjectContext
    private var managedContextHasBeenSet : Bool = false
    
    private init() {
       
        managedObjectContext = NSManagedObjectContext(
            concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    }
    // set up manage context
    func setManagedContext(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.managedContextHasBeenSet = true
        let notes = NoteCoreDataHelper.readNotesFromCoreData(fromManagedObjectContext: self.managedObjectContext)
        currentIndex = NoteCoreDataHelper.count
        for (index, note) in notes.enumerated() {
            noteIndexToIdDict[index] = note.noteId
        }
    }
    // add note to core data
    func addNote(noteToBeAdded: DueNote) {
        if managedContextHasBeenSet {
            noteIndexToIdDict[currentIndex] = noteToBeAdded.noteId
            NoteCoreDataHelper.createNoteInCoreData(
                noteToBeCreated:          noteToBeAdded,
                intoManagedObjectContext: self.managedObjectContext)
            currentIndex += 1
        }
    }
    // remove note from core data
    func removeNote(at: Int) {
        if managedContextHasBeenSet {
            if at < 0 || at > currentIndex-1 {
                return
            }
         
            let noteUUID = noteIndexToIdDict[at]
            NoteCoreDataHelper.deleteNoteFromCoreData(
                noteIdToBeDeleted:        noteUUID!,
                fromManagedObjectContext: self.managedObjectContext)
        
            if (at < currentIndex - 1) {
                
                for i in at ... currentIndex - 2 {
                    noteIndexToIdDict[i] = noteIndexToIdDict[i+1]
                }
            }
           
            noteIndexToIdDict.removeValue(forKey: currentIndex)
           
            currentIndex -= 1
        }
    }
    //read note from core data
    func readNote(at: Int) -> DueNote? {
        if managedContextHasBeenSet {
     
            if at < 0 || at > currentIndex-1 {
              
                return nil
            }
           
            let noteUUID = noteIndexToIdDict[at]
            let noteReadFromCoreData: DueNote?
            noteReadFromCoreData = NoteCoreDataHelper.readNoteFromCoreData(
                noteIdToBeRead:           noteUUID!,
                fromManagedObjectContext: self.managedObjectContext)
            return noteReadFromCoreData
        }
        return nil
    }
    // change note
    func changeNote(noteToBeChanged: DueNote) {
        if managedContextHasBeenSet {
           
            var noteToBeChangedIndex : Int?
            noteIndexToIdDict.forEach { (index: Int, noteId: UUID) in
                if noteId == noteToBeChanged.noteId {
                    noteToBeChangedIndex = index
                    return
                }
            }
            if noteToBeChangedIndex != nil {
                NoteCoreDataHelper.changeNoteInCoreData(
                noteToBeChanged: noteToBeChanged,
                inManagedObjectContext: self.managedObjectContext)
            } else {
           
            }
        }
    }
//    func updateCurrentTime(noteToBeChanged: DueNote){
//        
//    }

    
    func count() -> Int {
        return NoteCoreDataHelper.count
    }
}
