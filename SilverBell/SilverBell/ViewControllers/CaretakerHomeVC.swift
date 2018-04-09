//
//  HomeVC.swift
//  SilverBell
//
//  Created by Jackson Rossborough on 12/9/17.
//  Copyright © 2017 Jackson Rossborough. All rights reserved.
//

import UIKit
import Foundation


class CaretakerHomeVC: UIViewController {
    
    // MARK: Methods
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

