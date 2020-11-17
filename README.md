# UIFragmentDelegate
Simple and fast fragments for your application. 

Fast setup:

import UIFragmentDelegate

lazy var fragmentDelegate = UIFragmentDelegate(parentVC: parenVC, fragmentVC: fragmentVC, side: .bottom)
.
//parentVC - VC which shows your FragmentVC. Also i use bottom side as example. Chooose what would you like.

fragmentDelegate.intend = 100
fragmentDelegate.show(animated: true, completion: nil)

