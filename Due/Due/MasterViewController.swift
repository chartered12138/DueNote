//
//  MasterViewControllerTableViewController.swift
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//
import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    private(set) var changingNote : DueNote?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor=UIColor.systemGray6
        
        tableView.rowHeight = UITableView.automaticDimension
        
        
        // Core data initialization
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            // create alert
            let alert = UIAlertController(
                title: "Could note get app delegate",
                message: "Could note get app delegate, unexpected error occurred. Try again later.",
                preferredStyle: .alert)
            
            // add OK action
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default))
            // show alert
            self.present(alert, animated: true)
            
            return
        }
        
        // As we know that container is set up in the AppDelegates so we need to refer that container.
        // We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // set context in the storage
        NoteStorage.storage.setManagedContext(managedObjectContext: managedContext)
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        //        if let split = splitViewController {
        //            let controllers = split.viewControllers
        //            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        
        //        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "showCreateNoteSegue", sender: self)
    }
    
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NoteStorage.storage.count()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailvc = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController
        else{return}
        let object = NoteStorage.storage.readNote(at: indexPath.row)
        detailvc.detailItem = object
        showDetailViewController(detailvc, sender: self)
    }
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NoteUITableViewCell
        cell.backgroundColor=UIColor.systemFill
        setupTimer(for: cell, row: indexPath.row)
        return cell
    }
    private func getImage(isSubmitted: Bool,seconds: Int64) -> UIImage{
        if (isSubmitted){
            return UIImage(named:"checkmark")!
        }
        if (seconds<=0){
            return UIImage(named: "x-red")!
        }else if (seconds<=3600){
            return UIImage(named: "flame-red")!
        }else if (seconds<=18000){
            return UIImage(named: "flame-pink")!
        }else if (seconds<=86400){
            return UIImage(named: "exclamationmark-orange")!
        }else if (seconds<=259200){
            return UIImage(named: "clock-yellow")!
        }else if (seconds<=604800){
            return UIImage(named: "clock-lightGreen")!
        }else if (seconds<=1209600){
            return UIImage(named: "clock-green")!
        }else{
            return UIImage(named: "clock-darkGreen")!
        }
        
    }
    private func setupTimer(for cell: NoteUITableViewCell, row: Int) {
        if let object = NoteStorage.storage.readNote(at: row) {
            cell.titleLabel!.text = object.noteTitle
            
            cell.timeRemainingLabel!.text = self.timeRemainingToStr(isSubmitted: object.isSubmitted,secondsDifference: object.dueDate - Date().toSeconds())
            if (object.isSubmitted){
                cell.timeRemainingLabel!.textColor = .systemGreen
            }else{
                if(object.dueDate-Date().toSeconds()<=0){
                    cell.timeRemainingLabel!.textColor = .systemRed
                }else if(object.dueDate-Date().toSeconds()<=10800){
                    cell.timeRemainingLabel!.textColor = .systemOrange
                }else{
                    cell.timeRemainingLabel!.textColor = .label
                }
            }
            cell.dueDateLabel!.text = NoteDateHelper.convertDate(date: Date.init(seconds: object.dueDate))
            
            cell.iconImage.image = getImage(isSubmitted: object.isSubmitted,seconds: object.dueDate - Date().toSeconds())
            
        }
        
        
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { capturedTimer in
            if let object = NoteStorage.storage.readNote(at: row) {
                cell.titleLabel!.text = object.noteTitle
                cell.timeRemainingLabel!.text = self.timeRemainingToStr(isSubmitted: object.isSubmitted,secondsDifference: object.dueDate - Date().toSeconds())
                if (object.isSubmitted){
                    cell.timeRemainingLabel!.textColor = .systemGreen
                }else{
                    if(object.dueDate-Date().toSeconds()<=0){
                        cell.timeRemainingLabel!.textColor = .systemRed
                    }else if(object.dueDate-Date().toSeconds()<=10800){
                        cell.timeRemainingLabel!.textColor = .systemOrange
                    }else{
                        cell.timeRemainingLabel!.textColor = .label
                    }
                }
                cell.dueDateLabel!.text = NoteDateHelper.convertDate(date: Date.init(seconds: object.dueDate))
                cell.iconImage.image = self.getImage(isSubmitted: object.isSubmitted,seconds: object.dueDate - Date().toSeconds())
            }
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    private func submitToggle(object:DueNote) -> Void {
        NoteStorage.storage.changeNote(
            noteToBeChanged: DueNote(
                noteId:        object.noteId,
                noteTitle:     object.noteTitle,
                noteText:      object.noteText,
                isSubmitted: !object.isSubmitted,
                dueDate: object.dueDate)
        )
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive,title: "Delete"){ _, indexPath in
            NoteStorage.storage.removeNote(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        let submitActionTitle =  NoteStorage.storage.readNote(at: indexPath.row)!.isSubmitted ? "In progress" : "Submitted"
        
        let submitAction = UITableViewRowAction(style: .normal,title: submitActionTitle){ _, indexPath in
            if let object = NoteStorage.storage.readNote(at: indexPath.row){
                self.submitToggle(object: object)
            }
        }
        if (submitActionTitle == "Submitted"){
            submitAction.backgroundColor = .systemGreen
        }else{
            submitAction.backgroundColor = .systemOrange
        }
        return [deleteAction,submitAction]
    }
    
    
}

