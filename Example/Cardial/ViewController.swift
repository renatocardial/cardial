//
//  ViewController.swift
//  Cardial
//
//  Created by Renato Cardial on 03/08/2020.
//  Copyright (c) 2020 Renato Cardial. All rights reserved.
//

import UIKit
import Cardial

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NetworkProvider.setDebug(debug: true)
        NetworkProvider.request(api: MarvelAPI(), path: MarvelPath.characters.rawValue, model: Hero.self, offlineMode: true) { (response) in
            printAny(response)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

