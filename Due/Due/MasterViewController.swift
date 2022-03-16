//
//  MasterViewControllerTableViewController.swift
//  Due
//
//  Created by Shaoquan Qin on 2022/2/21.
//
import UIKit
import WhatsNewKit

class MasterViewController: UITableViewController {
    let defaultGrayScale = UserDefaults.standard.integer(forKey: "gray_scale")
   // read gray scale of background color from settings, default gray6
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
    
    var detailViewController: DetailViewController? = nil
    private(set) var changingNote : DueNote?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor=defaultBackGroundGray(grayScale: defaultGrayScale)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        
       
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      
            let alert = UIAlertController(
                title: "Could note get app delegate",
                message: "Could note get app delegate, unexpected error occurred. Try again later.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default))
            self.present(alert, animated: true)
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        NoteStorage.storage.setManagedContext(managedObjectContext: managedContext)
        // the add button at the top right corner of the master view controller
        navigationItem.leftBarButtonItem = editButtonItem
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // use whatsnew kit to display splash screen
        let whatsNew = WhatsNew(title: "Due by Shaoquan Qin", items: [
            WhatsNew.Item(title: "Add a new Due", subtitle: "You can add a new due by clicking on the plus sign in the top right corner", image: UIImage(systemName: "plus")),
            WhatsNew.Item(title: "View current Due", subtitle: "You can click on each due to see the details of the due", image: UIImage(systemName: "rectangle.portrait.and.arrow.right")),
            WhatsNew.Item(title: "Edit existing due", subtitle: "In the detail page, you can edit the current due", image: UIImage(systemName: "pencil")),
            WhatsNew.Item(title: "Submitted/In progress or delete", subtitle: "If you swipe the item to the left or click 'edit', you can update the due situation", image: UIImage(systemName: "delete.left")),
        ])
        
        let vc = WhatsNewViewController(whatsNew: whatsNew, theme: .red)
        // at the first launch, record the first launch date and present the splash screen,
        // at the third launch, present an alert view to let users rate this app
        // at the tenth launch, direct the user to go to settings to update the gray scale of background color
        let numberOfLaunches = UserDefaults.standard.integer(forKey: "numberOfLaunches")
        if numberOfLaunches == 0 {
            UserDefaults.standard.set(Date(), forKey: "first launch date")
            print(UserDefaults.standard.object(forKey: "first launch date"))
            present(vc,animated:true)
        }else if (numberOfLaunches == 3){
            print("Number of launches: "+String(numberOfLaunches))
            UserDefaults.standard.set(numberOfLaunches+1, forKey: "numberOfLaunches")
            let dialogMessage = UIAlertController(title: "Due", message: "Are you willing to rate this app?", preferredStyle: .alert)
             let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                 print("Ok button tapped")
              })
             dialogMessage.addAction(ok)
             self.present(dialogMessage, animated: true, completion: nil)
        }else if (numberOfLaunches == 10){
            print("Number of launches: "+String(numberOfLaunches))
            UserDefaults.standard.set(numberOfLaunches+1, forKey: "numberOfLaunches")
            let dialogMessage = UIAlertController(title: "Settings", message: "Do you want to set the gray scale of this app's background color in settings?", preferredStyle: .alert)
             let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
                 print("Cancel button tapped")
              })
            let go = UIAlertAction(title: "Go", style: .default, handler: { (action) -> Void in
                print("Go button tapped")
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.openURL(settingsUrl!)
             })
             dialogMessage.addAction(cancel)
             dialogMessage.addAction(go)
             self.present(dialogMessage, animated: true, completion: nil)
        }
        
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
    // prepare segue to show detail of specific due
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = NoteStorage.storage.readNote(at: indexPath.row)
                let controller = segue.destination as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    // given seconrds difference, return a string displayed on screen
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
    
    // for each cell, update the elements
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NoteUITableViewCell
        cell.backgroundColor=UIColor.systemFill
        setupTimer(for: cell, row: indexPath.row)
        return cell
    }
    // return the image given by seconds difference
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
    // a timer to update the elements of cells with an interval of 1s
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
    
    // if a task is submitted, change the isSubmitted in the core data
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
    
    // create two edit action, submitted/in progress and delete
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

