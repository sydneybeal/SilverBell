//
//  CaretakerProfileVC.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 2/5/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit

class CaretakerProfileVC: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBAction func sendMessage(_ sender: Any) {
        self.performSegue(withIdentifier: "profileToChat", sender: self)
        }
    
    var profile: Caretaker?
    
    @objc func pushToUserMesssages(notification: NSNotification) {
        if let user = notification.userInfo?["user"] as? Caretaker {
            self.profile = user
            self.performSegue(withIdentifier: "profileToChat", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToChat" {
            let vc = segue.destination as! ChatVC
            vc.currentUser = self.profile!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = profile?.name
        self.emailLabel.text = profile?.email
        self.profilePic.image = profile?.profilePic
        self.ratingControl.rating = (profile?.rating)!

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
