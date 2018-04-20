//
//  NewRequestVC.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 4/20/18.
//  Copyright © 2018 Jackson Rossborough. All rights reserved.
//

import UIKit
import Firebase

class NewRequestVC: UIViewController {
    
    @IBOutlet weak var requestDate: UITextField!
    @IBOutlet weak var requestTime: UITextField!
    @IBOutlet weak var requestAdditionalInfo: UITextView!
    
    var caretaker : Caretaker?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendRequest(_ sender: Any) {
        requestAdditionalInfo.resignFirstResponder()
        requestDate.resignFirstResponder()
        requestTime.resignFirstResponder()
        
        if let id = Auth.auth().currentUser?.uid {
            Request.createRequest(uidUser: id, uidCaretaker: (caretaker?.id)!, date: self.requestDate.text!, time: self.requestTime.text!, additionalInfo: self.requestAdditionalInfo.text!, completion: {(complete) in
                DispatchQueue.main.async {
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                }
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
