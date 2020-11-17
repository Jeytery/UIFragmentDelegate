
//
//  UIFragmentDelegate.swift
//  3bit_client
//
//  Created by Jeytery on 11/16/20.
//  Copyright © 2020 Epsillent. All rights reserved.
//

import UIKit

/* version 1.0 */

enum Side {
    case left
    case right
    case bottom
    case top
}

enum Effect {
    case blur
    case blackout
}

enum Action {
    case show
    case hide
}

class UIFragmentDelegate {

    public var parentVC: UIViewController?
    public var fragmentVC: UIViewController
    public var side: Side = .bottom
    public var effectIntensity: CGFloat = 0.7
    public var intend: Int = 300
    public var effect: Effect? = nil

    private var fragmentData: (x: Int, y: Int, deltaX: Int, deltaY: Int, height: Int, width: Int, size: Int) = (x: 0, y: 0, deltaX: 0, deltaY: 0, height: 0, width: 0, size: 0)
    private var blackoutView = UIView()
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var isToogled: Bool = false
    private var blockBoth: Bool = false
    private var layer: Int = 0
    private let screenSize = UIScreen.main.bounds.size
    private let closeGestureIdleState: Float = 60

    //MARK: - internal functions

    init(parentVC: UIViewController?, fragmentVC: UIViewController, side: Side) {
        self.parentVC = parentVC
        self.fragmentVC = fragmentVC
        self.side = side
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
                self.fragmentData.x = 0
                self.fragmentData.y = Int(self.screenSize.height)
                self.fragmentData.width = Int(screenSize.width)
                self.fragmentData.height = Int(self.screenSize.height) - self.intend
                self.fragmentData.deltaX = 0
                self.fragmentData.deltaY = Int(self.screenSize.height) - self.fragmentData.height
            case .left:
                self.fragmentData.x = -(Int(self.screenSize.width) - self.intend)
                self.fragmentData.y = 0
                self.fragmentData.width = Int(self.screenSize.width) - self.intend
                self.fragmentData.height = Int(self.screenSize.height)
                self.fragmentData.deltaX = 0
                self.fragmentData.deltaY = 0
            case .right:
                self.fragmentData.x = Int( (screenSize.width) )
                self.fragmentData.y = 0
                self.fragmentData.width = Int(Int(screenSize.width) - self.intend)
                self.fragmentData.height = Int(self.screenSize.height)
                self.fragmentData.deltaX = Int(self.screenSize.width) - self.fragmentData.width
                self.fragmentData.deltaY = 0
            case .top:
                self.fragmentData.x = 0
                self.fragmentData.y = -(Int(screenSize.height) - self.intend)
                self.fragmentData.width = Int(self.screenSize.width)
                self.fragmentData.height = Int(screenSize.height) - self.intend
                self.fragmentData.deltaX = 0
                self.fragmentData.deltaY = 0
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
        guard parentVC != nil else {print("parentVC is nil"); return}
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
        guard parentVC != nil else {print("parentVC is nil"); return}
        switch self.effect {
            case .blackout:
                self.blackoutView.backgroundColor = .black
                self.blackoutView.frame = parentVC!.view.frame
                self.blackoutView.alpha = 0
                self.parentVC!.view.insertSubview(blackoutView, belowSubview: self.fragmentVC.view)
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCloseGesture))
                self.blackoutView.addGestureRecognizer(gestureRecognizer)
                guard animated == true else{
                    self.blackoutView.alpha = 0.7
                    return
                }
                self.animate(animate: {self.blackoutView.alpha = 0.7}, completion: nil)
                break
            case .blur:
                self.blurView.frame = parentVC!.view.frame
                self.blurView.alpha = 0
                self.parentVC!.view.insertSubview(blurView, belowSubview: self.fragmentVC.view)
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCloseGesture))
                self.blurView.addGestureRecognizer(gestureRecognizer)
                guard animated == true else{
                    self.blurView.alpha = 0.7
                    return
                }
                self.animate(animate: {self.blurView.alpha = 1}, completion: nil)
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
            case .none:
                return
        }
    }

    @objc func tapCloseGesture() {
        self.hide(animated: true, completion: nil)
    }

    private func getDiaposon() -> (a: ClosedRange<Float>, b: ClosedRange<Float>) {
        var a: ClosedRange<Float>           // from (side)
        var b: ClosedRange<Float> = 0...1.0 // to (effect)
        if self.effect == .blackout { b = 0...0.7} else if self.effect == .blur { b = 0...0.7 }
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
                return 0.7 - converDiaposon(value: value, diaposonA: getDiaposon().a, diaposonB: getDiaposon().b)
            case .top:
                return converDiaposon(value: value, diaposonA: getDiaposon().a, diaposonB: getDiaposon().b)
            case .left:
                return converDiaposon(value: value, diaposonA: getDiaposon().a, diaposonB: getDiaposon().b)
            case .right:
                return 0.7 - converDiaposon(value: value, diaposonA: getDiaposon().a, diaposonB: getDiaposon().b)
        }
    }

    private func setEffectAlpha(value: Float) {
        guard effect != nil else {return}
        if effect == .blackout {
            self.blackoutView.alpha = CGFloat(getAlphaValue(value: value))
        } else if effect == .blur {
            self.blurView.alpha = CGFloat(getAlphaValue(value: value))
        }
    }

    private func closeGestureCompletion(value: Float) {
        let coords = getDiaposon()
        switch side {
            case .bottom:
                if value < coords.a.lowerBound + closeGestureIdleState { // minY
                    setFrame(animated: true, action: .show, completion: nil)
                } else {
                    hide(animated: true, completion: nil)
                }
                break
            case .top:
                if value > coords.a.upperBound - closeGestureIdleState { // maxY
                    setFrame(animated: true, action: .show, completion: nil)
                } else {
                    hide(animated: true, completion: nil)
                }
            case .left:
                if value > coords.a.upperBound - closeGestureIdleState { // maxX
                    setFrame(animated: true, action: .show, completion: nil)
                } else {
                    hide(animated: true, completion: nil)
                }
            case .right:
                if value < coords.a.lowerBound + closeGestureIdleState { // minX
                    setFrame(animated: true, action: .show, completion: nil)
                } else {
                    hide(animated: true, completion: nil)
                }
        }
        if self.effect == .blackout {
            animate(animate: {self.blackoutView.alpha = CGFloat(0.7)}, completion: nil)
        } else if self.effect == .blur {
            animate(animate: {self.blackoutView.alpha = CGFloat(1)}, completion: nil)
        }

    }

    @objc func closeGesture (_ sender: UIPanGestureRecognizer) {
        let view = sender.view!
        var dy: CGFloat = 0
        var dx: CGFloat = 0
        guard side == .left || side == .right else {
            switch sender.state {
                case .changed:
                    let translation = sender.translation(in: self.fragmentVC.view)
                    dy = view.center.y + translation.y
                    dx = view.center.x
                    if dy > screenSize.height - (view.frame.height / 2) && side == .bottom {
                        view.center = CGPoint(x: dx, y: dy)
                        setEffectAlpha(value: Float(view.layer.frame.minY))
                    } else if dy < view.frame.height / 2 && side == .top {
                        view.center = CGPoint(x: dx, y: dy)
                        setEffectAlpha(value: Float(view.layer.frame.maxY))
                    }
                    sender.setTranslation(CGPoint.zero, in: self.fragmentVC.view)
                    break
                case .ended:
                    if side == .bottom {
                        closeGestureCompletion(value: Float(view.layer.frame.minY))
                    } else if side == .top {
                        closeGestureCompletion(value: Float(view.layer.frame.maxY))
                    }
                    break
                default:
                    break
            }
            return
        }

        switch sender.state {
            case .changed:
                let translation = sender.translation(in: self.fragmentVC.view)
                dy = view.center.y
                dx = view.center.x + translation.x
                if dx < view.frame.width / 2 && side == .left {
                    view.center = CGPoint(x: dx, y: dy)
                    setEffectAlpha(value: Float(view.layer.frame.maxX))
                } else if dx > screenSize.width - (view.frame.width / 2) && side == .right {
                    view.center = CGPoint(x: dx, y: dy)
                    setEffectAlpha(value: Float(view.layer.frame.minX))
                }
                sender.setTranslation(CGPoint.zero, in: self.fragmentVC.view)
                break
            case .ended:
                if side == .left {
                    closeGestureCompletion(value: Float(view.layer.frame.maxX))
                } else if side == .right {
                    closeGestureCompletion(value: Float(view.layer.frame.minX))
                }
                break
            default:
                break
        }
    }

    //MARK: - public functions

    public func show(animated: Bool, completion: ( () -> Void)? ) {
        guard isToogled == false && blockBoth == false else {return}
        self.isToogled = !self.isToogled
        self.blockBoth = true
        initialise()
        setFrame(animated: animated, action: .show, completion: nil)
        completion?()
        guard self.effect != nil else {return}
        self.showEffect(animated: true)
    }

    public func hide(animated: Bool, completion: ( () -> Void)? ) {
        guard isToogled == true && blockBoth == false else {return}
        self.isToogled = !isToogled
        self.blockBoth = true
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

    public func activateEffect(effect: Effect) {
        self.effect = effect
    }

    public func activateCloseGesture() {
        let closeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(closeGesture))
        self.fragmentVC.view.addGestureRecognizer(closeGestureRecognizer)
    }
}
