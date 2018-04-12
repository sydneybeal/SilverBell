//
//  TableViewController.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 4/9/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import Firebase

class RequestHistoryTableVC: UITableViewController {

    var items = [Request]()
    var selectedRequest: Request?
    var caretakerItems = [Caretaker]()
    
    @IBOutlet var RequestHistoryTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRequests()
        fetchCaretakers()
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
        print(items.count)
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RequestHistoryViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RequestHistoryViewCell  else {
            fatalError("The dequeued cell is not an instance of RequestHistoryViewCell.")
        }
        let item = items[indexPath.row]
        let caretakerItem = caretakerItems[indexPath.row]
        
        cell.nameLabel.text = caretakerItem.name
        cell.dateLabel.text = item.date
        cell.timeLabel.text = item.time
        cell.profilePic.image = caretakerItem.profilePic
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.items.count > 0 {
            self.selectedRequest = self.items[indexPath.row]
            self.performSegue(withIdentifier: "requestSegue", sender: self)
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
    
    func customization() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToCaretakerProfile(notification:)), name: NSNotification.Name(rawValue: "showRequest"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestSegue" {
            let vc = segue.destination as! RequestVC
            vc.request = self.selectedRequest
        }
    }
    
    func fetchRequests()  {
        if let id = Auth.auth().currentUser?.uid {
            Request.downloadAllRequestsUser(uidUser: id, completion: {(request) in
                DispatchQueue.main.async {
                    self.items.append(request)
                }
            })
        }
    }
    
    func fetchCaretakers()  {
        for request in items {
            Caretaker.info(forUserID: request.uidCaretaker, completion: {(caretaker) in
                DispatchQueue.main.async {
                    self.caretakerItems.append(caretaker)
                    self.RequestHistoryTableView.reloadData()
                }
            })
        }
    }
    
    @objc func pushToCaretakerProfile(notification: NSNotification) {
        if let request = notification.userInfo?["request"] as? Request {
            self.selectedRequest = request
            self.performSegue(withIdentifier: "requestSegue", sender: self)
        }
    }

}
