//
//  LoaderViewController.swift
//  Twittermenti
//
//  Created by Darshil Agrawal on 08/08/21.
//  Copyright © 2021 London App Brewery. All rights reserved.
//

import UIKit
import Lottie
class LoaderViewController: UIViewController {

    @IBOutlet weak var loaderView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
     func showView() {
        loaderView.loopMode = .loop
        loaderView.play()
    }
    
    func hideView() {
        self.view.removeFromSuperview()
        loaderView.stop()
        loaderView.isHidden = true
    }
}
