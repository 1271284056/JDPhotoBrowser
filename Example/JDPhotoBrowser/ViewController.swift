//
//  ViewController.swift
//  JDPhotoBrowser
//
//  Created by 1271284056 on 06/12/2017.
//  Copyright (c) 2017 1271284056. All rights reserved.
//

import UIKit
import JDPhotoBrowser

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let vc = ViewControllerTest()
        vc.view.JDy = 100
        self.addChildViewController(vc)
        self.view.addSubview(vc.view)

    }


}

