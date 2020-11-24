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
        delegate.show(animated: true , completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate.activateEffect(effect: .blackout)

        delegate.activateCloseGesture()
        delegate.side = .left
        delegate.setFrameEdges( edges: (bottom: 50, top: 50, left: 0, right: 0), cornerRadius: (corners: [.topRight, .bottomRight], radius: 30) )
        delegate.intend = 100
    }
}
