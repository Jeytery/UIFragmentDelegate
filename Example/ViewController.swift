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
    lazy var delegate = UIFragmentDelegate(parentVC: self, fragmentVC: fragmentVC)

    @IBAction func button(_ sender: Any) {
        delegate.show(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fragmentVC.optAction = {
            print("hello fragment!")
        }

        delegate.setShape(edges: (top: 20, bottom: 20, left: 20, right: 20), cornerRadius: ([.allCorners], radius: 20))
        delegate.activateEffect(effect: .blackout, intensity: 0.9)
        delegate.activateCloseGesture()
        delegate.side = .bottom

    }

}
