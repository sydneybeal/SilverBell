//
//  CaretakerTableViewController.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 2/5/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import Firebase

class CaretakerTableVC: UITableViewController {
    
    // MARK: Properties
    
    var items = [User]()
    
    @IBOutlet weak var caretakerTableView: UITableView!
    @IBAction func Back(_ sender: UIButton) {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeVC
            pvc?.present(vc, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserInfo()
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
        print(items.count)
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CaretakerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CaretakerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CaretkaerTableViewCell.")
        }
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.profilePic.image = item.profilePic
        
        return cell
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
    
    func fetchUsers()  {
        if let id = Auth.auth().currentUser?.uid {
            print("downloading users")
            User.downloadAllUsers(exceptID: id, completion: {(user) in
                DispatchQueue.main.async {
                    self.items.append(user)
                    self.caretakerTableView.reloadData()
                }
            })
        }
        else
        {
            print("could not sign in")
        }
    }
    
    func fetchUserInfo() {
        if let id = Auth.auth().currentUser?.uid {
            User.info(forUserID: id, completion: {[weak weakSelf = self] (user) in
                DispatchQueue.main.async {
                    //weakSelf?.nameLabel.text = user.name
                    //weakSelf?.emailLabel.text = user.email
                    //weakSelf?.profilePicView.image = user.profilePic
                    weakSelf = nil
                }
            })
        }
    }
}
