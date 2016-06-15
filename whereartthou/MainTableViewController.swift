//
//  MainTableViewController.swift
//  whereartthou
//
//  Created by Leonid Rusnac on 14/06/16.
//  Copyright © 2016 Leonid Rusnac. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class MainTableViewController: UITableViewController, CLLocationManagerDelegate  {
    var rooms = [Room]()

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        self.retreiveData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addNewRoom(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New room", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Add", style: .Default) { action -> Void in
            if let alertTextField = alert.textFields?.first where alertTextField.text != nil {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext

                // create new room
                let entity = NSEntityDescription.entityForName("Room", inManagedObjectContext: managedContext)

                let room = Room(entity: entity!, insertIntoManagedObjectContext: managedContext)
                room.name = alertTextField.text!

                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save \(error), \(error.userInfo)")
                }

                self.retreiveData()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            // maybe call the server saying I don't care about this room anymore?
        })
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "room name"
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("room", forIndexPath: indexPath)

        cell.textLabel?.text = rooms[indexPath.row].name

        return cell
    }

    func retreiveData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let fetchRequest = NSFetchRequest(entityName: "Room")

        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            rooms = results as! [Room]
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch  \(error), \(error.userInfo)")
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let managedObjectContext = rooms[indexPath.row].managedObjectContext
            managedObjectContext?.deleteObject(rooms[indexPath.row])
            if let _ = try? managedObjectContext?.save() {
            }
            rooms.removeAtIndex(indexPath.item) // delete from core data instead
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRoomDetail" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(cell)
                if let index = indexPath?.row {
                    if let roomDetailViewController = segue.destinationViewController as? RoomDetailViewController {
                        roomDetailViewController.room = rooms[index]
                    }
                }
            }
        }
    }

}
