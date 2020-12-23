
//
//  UIFragmentDelegate.swift
//  3bit_client
//
//  Created by Jeytery on 11/16/20.
//  Copyright © 2020 Epsillent. All rights reserved.
//

import UIKit

/* version b2.1 */

// bug with close effect [+]
// now version is in beta and looks like b2.1, where 'b' is beta [+]
// bug with blur intencity [+]
// add opportunity to change intensity of effect [+]

// blur is not cool
// add opportunity to break show/hide animation
// remake messages (with only 4 styles)
// want to have bounce effect while back gesture in the future

public enum Side {
    case left
    case right
    case bottom
    case top
}

public enum Effect {
    case blur
    case blackout
    case without
}

public enum Action {
    case show
    case hide
}

public enum MessageStyle {
    case standart
    case rounded
    case bottomRounded
    case strict
}

public struct UIFragmentParameters {

    var side: Side = .bottom
    var effectIntensity: CGFloat? = nil // nil
    var intend: Int = 300
    var effect: Effect? = nil
    var edges: (bottom: Int, top: Int, left: Int, right: Int) = (bottom: 0, top: 0, left: 0, right: 0)
    var corners: (corners: UIRectCorner, radius: Int)? = nil
    var closeGestureIdleState: Float = 60
    var layer: Int = 0

}

public class UIFragmentDelegate {

    public var parentVC: UIViewController?
    public var fragmentVC: UIViewController
    public var side: Side = .bottom
    public var effectIntensity: CGFloat? = nil
    public var intend: Int = 300
    public var effect: Effect? = nil
    public var edges: (bottom: Int, top: Int, left: Int, right: Int) = (bottom: 0, top: 0, left: 0, right: 0)
    public var corners: (corners: UIRectCorner, radius: Int)? = nil
    public var closeGestureIdleState: Float = 60

    private var fragmentData: (x: Int, y: Int, deltaX: Int, deltaY: Int, height: Int, width: Int, size: Int) = (x: 0, y: 0, deltaX: 0, deltaY: 0, height: 0, width: 0, size: 0)
    private var blackoutView = UIView()
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var isToogled: Bool = false
    private var blockBoth: Bool = false
    private var layer: Int = 0
    private let screenSize = UIScreen.main.bounds.size
    private var statusBarStatus: Bool = false

    //private var animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear)

    //MARK: - internal functions

    public init(parentVC: UIViewController?, fragmentVC: UIViewController) {
        self.parentVC = parentVC
        self.fragmentVC = fragmentVC
    }

    public init(parentVC: UIViewController?, fragmentVC: UIViewController, parameters: UIFragmentParameters) {
        self.parentVC = parentVC
        self.fragmentVC = fragmentVC
        setParameters(parameters: parameters)
    }

    private func setParameters(parameters: UIFragmentParameters) {
        self.side = parameters.side
        self.effectIntensity = parameters.effectIntensity!
        self.intend = parameters.intend
        self.effect = parameters.effect
        self.edges = parameters.edges
        self.corners = parameters.corners
        self.closeGestureIdleState = parameters.closeGestureIdleState
    }

    private func converDiaposon(value: Float , diaposonA: ClosedRange<Float>, diaposonB: ClosedRange<Float>) -> Float {
        return (value-diaposonA.upperBound) / (diaposonA.lowerBound - diaposonA.upperBound) * (diaposonB.lowerBound - diaposonB.upperBound) + diaposonB.upperBound
    }

    private func animate( animate: @escaping () -> Void, completion: ( () -> Void)? ) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseIn,
            animations: {
                animate()
            }, completion: { (status) in
                completion?()
            })
    }

    private func setFragmentData() {
        switch self.side {
            case .bottom:
                self.fragmentData.x = 0 + self.edges.left
                self.fragmentData.y = Int(self.screenSize.height) + self.edges.top
                self.fragmentData.width = Int(screenSize.width - CGFloat(self.edges.left + self.edges.right))
                self.fragmentData.height = Int(self.screenSize.height) - (self.intend + self.edges.top + self.edges.bottom)
                self.fragmentData.deltaX = 0 + self.edges.left
                self.fragmentData.deltaY = Int(self.screenSize.height) - self.fragmentData.height - self.edges.bottom
            case .left:
                self.fragmentData.x = -(Int(self.screenSize.width) - self.intend) + self.edges.left
                self.fragmentData.y = 0 + self.edges.top
                self.fragmentData.width = Int(self.screenSize.width) - self.intend - (self.edges.right + self.edges.left)
                self.fragmentData.height = Int(self.screenSize.height) - (self.edges.top + self.edges.bottom)
                self.fragmentData.deltaX = 0 + self.edges.left
                self.fragmentData.deltaY = 0 + self.edges.top
            case .right:
                self.fragmentData.x = Int( (screenSize.width) )
                self.fragmentData.y = 0 + self.edges.bottom
                self.fragmentData.width = Int(Int(screenSize.width) - self.intend) - (self.edges.left + self.edges.right)
                self.fragmentData.height = Int(self.screenSize.height) - Int(self.edges.top + self.edges.bottom)
                self.fragmentData.deltaX = Int(self.screenSize.width) - self.fragmentData.width - self.edges.right
                self.fragmentData.deltaY = 0 + self.edges.bottom
            case .top:
                self.fragmentData.x = self.edges.left
                self.fragmentData.y = -(Int(screenSize.height) - self.intend) + self.edges.top
                self.fragmentData.width = Int(self.screenSize.width) - (self.edges.left + self.edges.right)
                self.fragmentData.height = Int(screenSize.height) - self.intend - (self.edges.top + self.edges.bottom)
                self.fragmentData.deltaX = self.edges.left
                self.fragmentData.deltaY = self.edges.top
        }
    }

    private func setFrame(animated: Bool, action: Action, completion: (() -> Void)? ) {
        guard animated else {
            if action == .show {
                self.fragmentVC.view.frame = CGRect(x: self.fragmentData.deltaX, y:  self.fragmentData.deltaY, width: self.fragmentData.width, height: self.fragmentData.height)
            } else if action == .hide {
                self.fragmentVC.view.frame = CGRect(x:  self.fragmentData.x, y:  self.fragmentData.y, width: self.fragmentData.width, height: self.fragmentData.height)
            }
            self.blockBoth = false
            completion?()
            return
        }

        animate(animate: {
            if action == .show {
                self.fragmentVC.view.frame = CGRect(x: self.fragmentData.deltaX, y:  self.fragmentData.deltaY, width: self.fragmentData.width, height: self.fragmentData.height)
            } else if action == .hide {
                self.fragmentVC.view.frame = CGRect(x:  self.fragmentData.x, y:  self.fragmentData.y, width: self.fragmentData.width, height: self.fragmentData.height)
            }
        }, completion: {
            self.blockBoth = false
            guard action == .hide else { return}
            self.deinitialise()
            completion?()
        })
    }

    private func initialise() {
        guard parentVC != nil else { print("parentVC is nil"); return }
        setFragmentData()
        self.fragmentVC.view.frame = CGRect(x: fragmentData.x, y: fragmentData.y, width: fragmentData.width, height: fragmentData.height)
        self.parentVC!.addChild(self.fragmentVC)
        self.parentVC!.view.addSubview(self.fragmentVC.view)
    }

    private func deinitialise () {
        self.fragmentVC.view.removeFromSuperview()
        self.fragmentVC.removeFromParent()
    }

    private func showEffect(animated: Bool) {
        guard parentVC != nil else { print("parentVC is nil"); return }
        switch self.effect {
            case .blackout:
                self.blackoutView.backgroundColor = .black
                self.blackoutView.frame = parentVC!.view.frame
                self.blackoutView.alpha = 0
                self.parentVC!.view.insertSubview(blackoutView, belowSubview: self.fragmentVC.view)
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCloseGesture))
                self.blackoutView.addGestureRecognizer(gestureRecognizer)
                guard animated == true else {
                    self.blackoutView.alpha = effectIntensity!
                    return
                }

                self.animate(animate: {self.blackoutView.alpha = self.effectIntensity!}, completion: nil)
                break
            case .blur:
                self.blurView.frame = parentVC!.view.frame
                self.blurView.alpha = 0
                self.parentVC!.view.insertSubview(blurView, belowSubview: self.fragmentVC.view)
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCloseGesture))
                self.blurView.addGestureRecognizer(gestureRecognizer)
                guard animated == true else{
                    self.blurView.alpha = effectIntensity!
                    return
                }
                self.animate(animate: {self.blurView.alpha = self.effectIntensity!}, completion: nil)
                break
            default:
                break

        }
    }

    private func hideEffect(animated: Bool) {
        switch self.effect {
            case .blackout:
                guard animated == true else {
                    self.blackoutView.alpha = 0
                    self.blackoutView.removeFromSuperview()
                    return
                }
                self.animate(animate: { self.blackoutView.alpha = 0 }, completion: { self.blackoutView.removeFromSuperview() })
                return
            case .blur:
                guard animated == true else {
                    self.blurView.alpha = 0
                    self.blurView.removeFromSuperview()
                    return
                }
                self.animate(animate: { self.blurView.alpha = 0 }, completion: { self.blurView.removeFromSuperview() })
                return
            case .without:
                break
            case .none:
                return
        }
    }

    @objc func tapCloseGesture() {
        self.hide(animated: true, completion: nil)
    }

    private func getDiaposon() -> (a: ClosedRange<Float>, b: ClosedRange<Float>) {
        var a: ClosedRange<Float>           // from (side)
        let b: ClosedRange<Float> = 0...Float(self.effectIntensity!) // to (effect)
        //if self.effect == .blackout { b = 0...0.7} else if self.effect == .blur { b = 0...0.7 }
        switch self.side {
            case .bottom:
                a = Float(self.screenSize.height - self.fragmentVC.view.frame.height)...Float(screenSize.height) // for minY
                return (a: a, b: b)
            case .top:
                a = Float(0)...Float(self.fragmentVC.view.frame.height) // for maxY
                return (a: a, b: b)
            case .left:
                a = Float(0)...Float(self.fragmentVC.view.frame.width) // for maxX
                return (a: a, b: b)
            case .right:
                a = Float(screenSize.width - self.fragmentVC.view.frame.width)...Float(screenSize.width) // for maxX
                return (a: a, b: b)
        }
    }

    private func getAlphaValue(value: Float) -> Float {
        switch self.side {
            case .bottom:
                return Float(effectIntensity!) - converDiaposon(value: value, diaposonA: getDiaposon().a, diaposonB: getDiaposon().b)
            case .top:
                return converDiaposon(value: value, diaposonA: getDiaposon().a, diaposonB: getDiaposon().b)
            case .left:
                return converDiaposon(value: value, diaposonA: getDiaposon().a, diaposonB: getDiaposon().b)
            case .right:
                return Float(effectIntensity!) - converDiaposon(value: value, diaposonA: getDiaposon().a, diaposonB: getDiaposon().b)
        }
    }

    private func setEffectAlpha(value: Float) {
        guard effect != nil else { return }
        if effect == .blackout {
            self.blackoutView.alpha = CGFloat(getAlphaValue(value: value ))
        } else if effect == .blur {
            self.blurView.alpha = CGFloat(getAlphaValue(value: value ))
        }
    }

    private func getDeadlock() -> CGFloat {
        switch self.side {
            case .bottom:
                return (self.screenSize.height - self.fragmentVC.view.frame.height) - CGFloat(self.edges.bottom)
            case .top:
                return self.fragmentVC.view.frame.height + CGFloat(self.edges.top)
            case .left:
                return 0 + self.fragmentVC.view.frame.width + CGFloat(self.edges.left)
            case .right:
                return self.screenSize.width - self.fragmentVC.view.frame.width - CGFloat(self.edges.right)
        }
    }

    private func closeGestureCompletion(value: Float) {
        let deadlock = getDeadlock()
        switch side {
            case .bottom:
                if value < Float(deadlock) + closeGestureIdleState { // minY
                    setFrame(animated: true, action: .show, completion: nil)
                } else {
                    self.hide(animated: true, completion: nil)
                }
                break
            case .top:
                if value + Float(self.edges.top) > Float(deadlock) - closeGestureIdleState { // maxY
                    setFrame(animated: true, action: .show, completion: nil)
                } else {
                    self.hide(animated: true, completion: nil)
                }
            case .left:
                if value + Float(self.edges.left) > Float(deadlock) - closeGestureIdleState { // maxX
                    setFrame(animated: true, action: .show, completion: nil)
                } else {
                    self.hide(animated: true, completion: nil)
                }
            case .right:
                if value - Float(self.edges.right) < Float(deadlock) + closeGestureIdleState { // minX
                    setFrame(animated: true, action: .show, completion: nil)
                } else {
                    self.hide(animated: true, completion: nil)
                }
        }

    }

    private func frameInc(translation: CGPoint) -> CGFloat {
        switch self.side {
            case .bottom:
                let deadlock = (self.screenSize.height - self.fragmentVC.view.frame.height) - CGFloat(self.edges.bottom)
                let dframe = self.fragmentVC.view.layer.frame.minY - deadlock
                if self.fragmentVC.view.frame.origin.y < deadlock {return self.fragmentVC.view.frame.origin.y} // guard >=
                else if -translation.y > CGFloat(dframe) { return deadlock }
                return self.fragmentVC.view.frame.origin.y + translation.y
            case .left:
                let deadlock = 0 + self.fragmentVC.view.frame.width + CGFloat(self.edges.left)
                let dframe: Double = Double(deadlock - self.fragmentVC.view.layer.frame.maxX)
                if self.fragmentVC.view.frame.maxX > deadlock { return 0 + CGFloat(self.edges.left) } // guard <=
                else if translation.x > CGFloat(dframe) { return 0 + CGFloat(self.edges.left) }
                return self.fragmentVC.view.frame.origin.x + translation.x
            case .right:
                let deadlock = self.screenSize.width - self.fragmentVC.view.frame.width - CGFloat(self.edges.right)
                let dframe = self.fragmentVC.view.frame.minX - deadlock
                if self.fragmentVC.view.frame.minX < deadlock { return deadlock }
                else if -translation.x > CGFloat(dframe) { return deadlock }
                return self.fragmentVC.view.frame.origin.x + translation.x
            case .top:
                let deadlock = self.fragmentVC.view.frame.height + CGFloat(self.edges.top)
                let dframe = deadlock - self.fragmentVC.view.frame.maxY
                if self.fragmentVC.view.frame.maxY > deadlock { return CGFloat(self.edges.top) } // guard >=
                else if translation.y > CGFloat(dframe) { return CGFloat(self.edges.top) }
                return self.fragmentVC.view.frame.origin.y + translation.y
        }
    }

    @objc func closeGesture (_ sender: UIPanGestureRecognizer) {
    
        let view = sender.view!

        guard self.side != .bottom && self.side != .top else {
            switch sender.state {
                case .changed:
                    let translation = sender.translation(in: view)
                    view.frame.origin = CGPoint(x: CGFloat(self.edges.left), y: frameInc(translation: translation))
                    setEffectAlpha(value: self.side == .bottom ? Float(self.fragmentVC.view.frame.minY + CGFloat(self.edges.bottom)) : Float(self.fragmentVC.view.frame.maxY - CGFloat(self.edges.top)) )
                    sender.setTranslation(CGPoint.zero, in: view)
                    break
                case .ended:
                    closeGestureCompletion(value: self.side == .bottom ? Float(self.fragmentVC.view.frame.minY + CGFloat(self.edges.bottom)) : Float(self.fragmentVC.view.frame.maxY - CGFloat(self.edges.top)))
                    break
                default:
                    break
            }
            return
        }

        switch sender.state {
            case .changed:
                let translation = sender.translation(in: view)
                view.frame.origin = CGPoint(x: frameInc(translation: translation), y: CGFloat(self.edges.top))
                setEffectAlpha(value: self.side == .left ? Float(self.fragmentVC.view.frame.maxX - CGFloat(self.edges.left)) : Float(self.fragmentVC.view.frame.minX + CGFloat(self.edges.right)) )
                sender.setTranslation(CGPoint.zero, in: view)
                break
            case .ended:
                closeGestureCompletion(value: self.side == .left ? Float(self.fragmentVC.view.frame.maxX - CGFloat(self.edges.left)) : Float(self.fragmentVC.view.frame.minX + CGFloat(self.edges.right)) )
                break
            default:
                break
        }
    }

    private func setMessageFrame(style: MessageStyle) {
        switch style {
            case .standart:
                self.setShape(edges: (bottom: 0, top: 0, left: 0, right: 0), cornerRadius: 0)
                break
            case .rounded:
                self.setShape(edges: (bottom: 30, top: 15, left: 15, right: 15), cornerRadius: 15)
                break
            case .bottomRounded:
                self.setShape(edges: (bottom: 0, top: 0, left: 0, right: 0), cornerRadius: (corners: [.bottomLeft, .bottomRight], radius: 15))
                break
            case .strict:
                self.setShape(edges: (bottom: 15, top: 15, left: 15, right: 15), cornerRadius: 0)
                break
        }
    }

    private func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.fragmentVC.view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.fragmentVC.view.layer.mask = mask
    }

    //MARK: - public functions

    public func show(animated: Bool, completion: ( () -> Void)? ) {
        guard isToogled == false && blockBoth == false else {return}
        self.isToogled = !self.isToogled
        self.blockBoth = true
        initialise()
        setFrame(animated: animated, action: .show, completion: nil)
        self.corners != nil ? self.roundCorners(corners: [corners!.corners], radius: CGFloat(self.corners!.radius)) :
        completion?()
        guard self.effect != nil else {return}
        self.showEffect(animated: true)
    }

    public func hide(animated: Bool, completion: ( () -> Void)? ) {
        guard isToogled == true && blockBoth == false else {return}
        self.isToogled = !isToogled
        self.blockBoth = true
        guard animated == true else {setFrame(animated: false, action: .hide, completion: nil); return}
        setFrame(animated: true, action: .hide, completion: nil)
        completion?()
        guard self.effect != nil else {return}
        hideEffect(animated: true)
    }

    public func setLayer(layer: Int) {
        guard parentVC != nil else {print("parentVC is nil"); return}
        self.parentVC!.view.insertSubview(self.fragmentVC.view, at: layer)
        setFragmentData()
        setFrame(animated: false, action: .hide, completion: nil)
    }

    public func activateEffect(effect: Effect, intensity: CGFloat?) {
        self.effect = effect
        self.effectIntensity = intensity
        if intensity == nil {
            if self.effect == .blackout { effectIntensity = 0.7 } else { effectIntensity = 0.5}
        }

    }

    public func activateCloseGesture() {
        let closeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(closeGesture))
        self.fragmentVC.view.addGestureRecognizer(closeGestureRecognizer)
    }

    public func setShape( edges: (bottom: Int, top: Int, left: Int, right: Int)?, cornerRadius: (UIRectCorner, radius: Int) ) {
        self.corners = cornerRadius
        guard edges != nil else {return}
        self.edges = edges!
    }

    public func setShape( edges: (bottom: Int, top: Int, left: Int, right: Int)?, cornerRadius: Int) {
        self.fragmentVC.view.layer.cornerRadius = CGFloat(cornerRadius)
        guard edges != nil else {return}
        self.edges = edges!
    }

}
