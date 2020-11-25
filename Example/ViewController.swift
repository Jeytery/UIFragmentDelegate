//
//  ViewController.swift
//  Example
//
//  Created by Jeytery on 11/20/20.
//  Copyright © 2020 Epsillent. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let fragmentVC = FragmentViewController()
    lazy var delegate = UIFragmentDelegate(parentVC: self, fragmentVC: fragmentVC, side: .bottom)

    @IBAction func button(_ sender: Any) {
        delegate.showMessage(duration: 3, lenght: 100, style: .rounded)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
