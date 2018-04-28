//
//  CaretakerTableViewController.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 2/5/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class CaretakerTableVC: UITableViewController {
    
    // MARK: Properties
    
    var items = [Caretaker]()
    var sortedItems = [Caretaker]()
    var sortedDistances = [CLLocationDistance]()
    var selectedUser: Caretaker?
    var numOfCaretakers = Int()
    
    @IBOutlet weak var caretakerTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print(items.count)
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CaretakerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CaretakerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CaretkaerTableViewCell.")
        }
        let item = sortedItems[indexPath.row]
        var distance = sortedDistances[indexPath.row]
        cell.nameLabel.text = item.name
        cell.profilePic.image = item.profilePic
        cell.ratingControl.rating = item.rating
        distance = distance * 0.000621
        var distanceString = String(format: "%.2f", distance)
        distanceString = "\(distanceString) mi"
        cell.distanceLabel.text = distanceString
        // m to mi is * by .000621
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.items.count > 0 {
            self.selectedUser = self.sortedItems[indexPath.row]
            self.performSegue(withIdentifier: "caretakerSegue", sender: self)
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Private Methods
    
    func customization() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToCaretakerProfile(notification:)), name: NSNotification.Name(rawValue: "showCaretakerProfile"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "caretakerSegue" {
            let vc = segue.destination as! CaretakerProfileVC
            vc.profile = self.selectedUser
        }
    }
    
    func fetchUsers()  {
        if let id = Auth.auth().currentUser?.uid {
            Caretaker.getCaretakerCount(completion: {(numCaretakers) in
                    self.numOfCaretakers = numCaretakers
            })
            Caretaker.downloadAllCaretakers(exceptID: id, completion: {(caretaker) in
                DispatchQueue.main.async {
                    self.items.append(caretaker)
                    //self.caretakerTableView.reloadData()
                }
            })
            self.sortUsers()
        }
    }
    
    func sortUsers() {
        if self.items.count == self.numOfCaretakers && self.numOfCaretakers != 0 {
            if let id = Auth.auth().currentUser?.uid {
                Caretaker.sortCaretakersByLocation(caretakers: self.items, uidUser: id) { (sortedItems, sortedDistances) in
                    DispatchQueue.main.async {
                        self.sortedDistances = sortedDistances
                        self.sortedItems = sortedItems
                        self.caretakerTableView.reloadData()
                    }
                }
            }
        } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.sortUsers()
                }
            }
    }
    
    @objc func pushToCaretakerProfile(notification: NSNotification) {
        if let caretaker = notification.userInfo?["user"] as? Caretaker {
            self.selectedUser = caretaker
            self.performSegue(withIdentifier: "caretakerSegue", sender: self)
        }
    }
    
}
