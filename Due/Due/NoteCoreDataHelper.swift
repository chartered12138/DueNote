//
//  NoteCoreDataHelper.swift
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//


import Foundation
import CoreData

class NoteCoreDataHelper {
    
    private(set) static var count: Int = 0
    // create note in core data
    static func createNoteInCoreData(
        noteToBeCreated:          DueNote,
        intoManagedObjectContext: NSManagedObjectContext) {
        

        let noteEntity = NSEntityDescription.entity(
            forEntityName: "Note",
            in:            intoManagedObjectContext)!
        
        let newNoteToBeCreated = NSManagedObject(
            entity:     noteEntity,
            insertInto: intoManagedObjectContext)

        newNoteToBeCreated.setValue(
            noteToBeCreated.noteId,
            forKey: "noteId")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteTitle,
            forKey: "noteTitle")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteText,
            forKey: "noteText")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.isSubmitted,
            forKey: "isSubmitted")
        newNoteToBeCreated.setValue(
            noteToBeCreated.dueDate,
            forKey: "dueDate")
        
        do {
            try intoManagedObjectContext.save()
            count += 1
        } catch let error as NSError {
            // TODO error handling
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    // change note in core data
    static func changeNoteInCoreData(
        noteToBeChanged:        DueNote,
        inManagedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdPredicate = NSPredicate(format: "noteId = %@", noteToBeChanged.noteId as CVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try inManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeChanged = fetchedNotesFromCoreData[0] as! NSManagedObject
            
            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteTitle,
                forKey: "noteTitle")

            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteText,
                forKey: "noteText")

            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.isSubmitted,
                forKey: "isSubmitted")

            
            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.dueDate,
                forKey: "dueDate")
            try inManagedObjectContext.save()

        } catch let error as NSError {
 
            print("Could not change. \(error), \(error.userInfo)")
        }
    }
    // read notes from core data, return a list of DueNote
    static func readNotesFromCoreData(fromManagedObjectContext: NSManagedObjectContext) -> [DueNote] {

        var returnedNotes = [DueNote]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.predicate = nil
        // sort the due date, present incoming deadline at top
        func sortingRule(n1: DueNote, n2: DueNote) -> Bool{
            return n1.dueDate < n2.dueDate
        }
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            fetchedNotesFromCoreData.forEach { (fetchRequestResult) in
                let noteManagedObjectRead = fetchRequestResult as! NSManagedObject
                returnedNotes.append(DueNote.init(
                    noteId:        noteManagedObjectRead.value(forKey: "noteId")        as! UUID,
                    noteTitle:     noteManagedObjectRead.value(forKey: "noteTitle")     as! String,
                    noteText:      noteManagedObjectRead.value(forKey: "noteText")      as! String,
                    isSubmitted: noteManagedObjectRead.value(forKey: "isSubmitted") as! Bool,
                    dueDate: noteManagedObjectRead.value(forKey: "dueDate") as! Int64))
            }
        } catch let error as NSError {
           
            print("Could not read. \(error), \(error.userInfo)")
        }
        
        
        self.count = returnedNotes.count
        returnedNotes = returnedNotes.sorted(by: sortingRule)
        // return a sorted list by due dates
        return returnedNotes
    }
    // read note with specific note id
    static func readNoteFromCoreData(
        noteIdToBeRead:           UUID,
        fromManagedObjectContext: NSManagedObjectContext) -> DueNote? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdPredicate = NSPredicate(format: "noteId = %@", noteIdToBeRead as CVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeRead = fetchedNotesFromCoreData[0] as! NSManagedObject
            return DueNote.init(
                noteId:        noteManagedObjectToBeRead.value(forKey: "noteId")        as! UUID,
                noteTitle:     noteManagedObjectToBeRead.value(forKey: "noteTitle")     as! String,
                noteText:      noteManagedObjectToBeRead.value(forKey: "noteText")      as! String,
                isSubmitted: noteManagedObjectToBeRead.value(forKey: "isSubmitted") as! Bool,
                dueDate: noteManagedObjectToBeRead.value(forKey: "dueDate") as! Int64)
        } catch let error as NSError {
    
            print("Could not read. \(error), \(error.userInfo)")
            return nil
        }
    }
    // delete note with specific id
    static func deleteNoteFromCoreData(
        noteIdToBeDeleted:        UUID,
        fromManagedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdAsCVarArg: CVarArg = noteIdToBeDeleted as CVarArg
        let noteIdPredicate = NSPredicate(format: "noteId == %@", noteIdAsCVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeDeleted = fetchedNotesFromCoreData[0] as! NSManagedObject
            fromManagedObjectContext.delete(noteManagedObjectToBeDeleted)
            
            do {
                try fromManagedObjectContext.save()
                self.count -= 1
            } catch let error as NSError {
              
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
          
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
    }

}
