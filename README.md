# UIFragmentDelegate 

 ![alt text](https://github.com/Jeytery/UIFragmentDelegate//blob/master/UIFragmentDelegate_v2.png?raw=true)

Simple and fast fragments for your application. 

## Fast setup 
```swift
import UIFragmentDelegate

class ParentViewController: UIViewController {

  // parentVC - VC which shows your fragment. Also i use bottom side as example. Chooose whatever would you like.
  // available: bottom, top, left , right
  
  let fragmentVC = FragmentViewController()
  lazy var fragmentDelegate = UIFragmentDelegate(parentVC: parenVC, fragmentVC: fragmentVC, side: .bottom)
  
  override func viewDidLoad {
    super.viewDidLoad()
    fragmentDelegate.intend = 100
    fragmentDelegate.show(animated: true, completion: nil)
  }

}
```

# Addition settings 
### Show Fragment on the Parent 
This is main function for you. When you set up your delegate you can show fragment whenever you want. Also you can add completion func
```swift
fragmentDelegate.show(animated: true , completion: nil)
fragmentDelegate.show(animated: false , completion: {print("hello world!")})
```
### Hide Fragment on the Parent 
The same as a show, but it hides fragment
```swift
fragmentDelegate.hide(animated: true , completion: nil)
fragmentDelegate.hide(animated: false , completion: {print("hello world!")})
```
### Fragment's layer on the Parent 
```swift
fragmentDelegate.setLayer(layer: 1)
```
### Effect during showing animation 
You can use two effects: blackout and blur. Also it activate tap close gesture and you can chagne it in the future 
```swift
fragmentDelegate.activateEffect(effect: .blackout)
fragmentDelegate.activateEffect(effect: .blur)
fragmentDelegate.effect = .blur 
```
### Close gesture 
Allow you to close fragment with gesture. You can adjust the point to which the fragment cannot be closed
```swift
fragmentDelegate.activateCloseGesture()
fragmentDelgate.closeGestureIdleState = 70 // standart is 60
```
### Set Shape of your fragment 
You can put whichever VC to the delegate on form its shape. There are two functions for this. You can set up intdend on all sides. Also you can round all corners with radius or several (second func). In example i round topLeft and topRight corners with radius 10
```swift
fragmentDelegate.setFrameEdges( edges: (bottom: 10, top: 10, left: 10, right: 10), cornerRadius: 10) // same func with radius for all corners 
fragmentDelegate.setFrameEdges( edges: (bottom: 10, top: 10, left: 10, right: 10), cornerRadius: ([.topLeft, .topRight], radius: 10))
```
