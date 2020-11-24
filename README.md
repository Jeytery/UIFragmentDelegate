# UIFragmentDelegate
Simple and fast fragments for your application. 

Fast setup:

import UIFragmentDelegate

lazy var fragmentDelegate = UIFragmentDelegate(parentVC: parenVC, fragmentVC: fragmentVC, side: .bottom)
.
//parentVC - VC which shows your FragmentVC. Also i use bottom side as example. Chooose what would you like.

fragmentDelegate.intend = 100
fragmentDelegate.show(animated: true, completion: nil)


// addition settings 

fragmentDelegate.setLayer(layer: 1)                // setLayer of fragmentVC on parentVC
fragmentDelegate.activateEffect(effect: .blackout) // effect when you show your fragment. Also has blur effect 
fragmentDelegate.activateCloseGesture()            // swipe gesture to close fragmentVC
fragmentDelegate.setFrameEdges( edges: (bottom: 10, top: 10, left: 10, right: 10), cornerRadius: ([.topLeft, .topRight], radius: 10)) // set corners radius and edges 
fragmentDelegate.setFrameEdges( edges: (bottom: 10, top: 10, left: 10, right: 10), cornerRadius: 10) // same func with radius for all corners 
fragmentDelegate.hide(animated: true, completion: nil) // hide fragment also can has completion callback func after completion. It can be nil as in this code stroke 
fragmentDelegate.hide(animated: true, completion: {print("end of function")}) // or can be not nil

