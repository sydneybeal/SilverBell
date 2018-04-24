//
//  CaretakerRequestVC.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 4/13/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import Firebase

class CaretakerRequestVC: UIViewController {
    
    var request: Request?
    var user: User?
    var status: String?
    
    @IBOutlet weak var caretakerPicView: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addtlInfo: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var acceptRequest: UIButton!
    
    func customization() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // use request accepted boolean to change status ui label
        self.setStatus();
        self.statusLabel.text = status
        // set remaining labels from req
        self.nameLabel.text = user?.name
        self.dateLabel.text = request?.date
        self.timeLabel.text = request?.time
        self.addtlInfo.text = request?.additionalInfo
        self.caretakerPicView.image = user?.profilePic
        self.ratingControl.rating = (user?.rating)!
        
    }
    
    func setStatus() {
        if request?.accepted == true {
            status = "Accepted"
            self.acceptRequest.isHidden = true
        } else {
            status = "Open"
            self.acceptRequest.isHidden = false
        }
    }
    
    @IBAction func acceptRequest(_ sender: Any) {
        if let id = Auth.auth().currentUser?.uid {
            Request.acceptRequest(tag: (request?.tag)!, uidUser: (request?.uidUser)!, uidCaretaker: id, completion: {(status) in
                if status == true {
                    super.viewDidLoad()
                    self.customization()
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
