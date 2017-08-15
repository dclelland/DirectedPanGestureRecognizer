//
//  DirectedPanGestureRecognizer.swift
//  DirectedPanGestureRecognizer
//
//  Created by Daniel Clelland on 5/03/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

/// Extension of `UIGestureRecognizerDelegate` which allows the delegate to receive messages when the pan gesture recognizer starts, updates, cancels, and finishes. The `delegate` property can be set to a class implementing `DirectedPanGestureRecognizerDelegate` and it will receive these messages.
@objc public protocol DirectedPanGestureRecognizerDelegate: UIGestureRecognizerDelegate {
    
    /// Called when the pan gesture recognizer starts.
    @objc optional func directedPanGestureRecognizer(didStart gestureRecognizer: DirectedPanGestureRecognizer)
    
    /// Called when the pan gesture recognizer updates.
    @objc optional func directedPanGestureRecognizer(didUpdate gestureRecognizer: DirectedPanGestureRecognizer)
    
    /// Called when the pan gesture recognizer cancels. A pan gesture recognizer may cancel if its translation or velocity in `initialDirection` is less than the value of `minimumTranslation` or `minimumVelocity`, respectively.
    @objc optional func directedPanGestureRecognizer(didCancel gestureRecognizer: DirectedPanGestureRecognizer)
    
    /// Called when the pan gesture recognizer finishes. A pan gesture recognizer may finish if its translation and velocity in `initialDirection` are greater than or equal to the value of `minimumTranslation` or `minimumVelocity`, respectively.
    @objc optional func directedPanGestureRecognizer(didFinish gestureRecognizer: DirectedPanGestureRecognizer)
    
}

open class DirectedPanGestureRecognizer: UIPanGestureRecognizer {
    
    /// The pan gesture recognizer's direction. Also used to calculate attributes for a given direction.
    public enum Direction {
        /// The pan gesture recognizer's touches move upwards.
        case up
        /// The pan gesture recognizer's touches move leftwards.
        case left
        /// The pan gesture recognizer's touches move downwards.
        case down
        /// The pan gesture recognizer's touches move rightwards.
        case right
    }
    
    // MARK: Configuration
    
    /// Minimum translation (in `initialDirection`) required for the gesture to finish. Defaults to `0.0`.
    @IBInspectable open var minimumTranslation: CGFloat = 0.0
    
    /// Minimum velocity (in `initialDirection`) required for the gesture to finish. Defaults to `0.0`.
    @IBInspectable open var minimumVelocity: CGFloat = 0.0
    
    // MARK: Internal variables
    
    /// The current location in `view` when the pan gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    open fileprivate(set) var initialLocation: CGPoint?
    
    /// The current direction in `view` when the pan gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    open fileprivate(set) var initialDirection: Direction?
    
    // MARK: Delegation
    
    open override var delegate: UIGestureRecognizerDelegate? {
        didSet {
            self.addTarget(self, action: #selector(onPan))
        }
    }
    
    internal var directedPanDelegate: DirectedPanGestureRecognizerDelegate? {
        return delegate as? DirectedPanGestureRecognizerDelegate
    }
    
    // MARK: Initialization
    
    /// Initialize the pan gesture recognizer with no target or action set.
    public convenience init() {
        self.init(target: nil, action: nil)
    }
    
    // MARK: Overrides
    
    open override func reset() {
        super.reset()
        
        initialLocation = nil
        initialDirection = nil
    }
    
    // MARK: Actions
    
    internal func onPan() {
        initialLocation = initialLocation ?? location
        initialDirection = initialDirection ?? direction
    
        switch state {
        case .began:
            directedPanDelegate?.directedPanGestureRecognizer?(didStart: self)
        case .changed:
            directedPanDelegate?.directedPanGestureRecognizer?(didUpdate: self)
        case .cancelled:
            directedPanDelegate?.directedPanGestureRecognizer?(didCancel: self)
        case .ended where shouldCancel():
            directedPanDelegate?.directedPanGestureRecognizer?(didCancel: self)
        case .ended:
            directedPanDelegate?.directedPanGestureRecognizer?(didFinish: self)
        default:
            break
        }
    }
    
    // MARK: Cancellation
    
    fileprivate func shouldCancel() -> Bool {
        return translation() < minimumTranslation || velocity() < minimumVelocity
    }

}

// MARK: - Dynamic variables

public extension DirectedPanGestureRecognizer {
    
    /// The pan gesture recognizer's current location in `view`, calculated using `location(in:)`. Returns `nil` if `view` is `nil`.
    public var location: CGPoint? {
        guard let view = view else {
            return nil
        }
        
        return location(in: view)
    }
    
    /// The pan gesture recognizer's current direction in `view`, calculated using `translation(in:)`. Returns `nil` if `view` is `nil`.
    public var direction: Direction? {
        guard let view = view else {
            return nil
        }
        
        let translation = self.translation(in: view)
        
        if (translation == .zero) {
            return nil
        } else if (fabs(translation.x) < fabs(translation.y)) {
            return translation.y > 0.0 ? .down : .up
        } else {
            return translation.x > 0.0 ? .right : .left
        }
    }
    
}

// MARK: - Directional helpers

public extension DirectedPanGestureRecognizer {
    
    /**
     The pan gesture recognizer's current translation in `view`, simplified to a linear value in a given direction.
     
     - parameter direction: The direction. Defaults to `nil`, in which case `initialDirection` is used.
     
     - returns: Returns `0.0` if either `direction` (or the `initialDirection` fallback) or `view` are `nil`. Else, takes the current `translation(in:)` and simplfies it down to the specified `direction`. For example, if `direction` is `.left`, and the translation is `CGPoint(x: 3.0, y: 4.0)`, the function returns `3.0`.
     */
    
    public func translation(inDirection direction: Direction? = nil) -> CGFloat {
        guard let direction = direction ?? initialDirection, let view = view else {
            return 0.0
        }
        
        return translation(in: view).magnitude(inDirection: direction)
    }
    
    /**
     The pan gesture recognizer's current velocity in `view`, simplified to a linear value in a given direction.
     
     - parameter direction: The direction. Defaults to `nil`, in which case `initialDirection` is used.
     
     - returns: Returns `0.0` if either `direction` (or the `initialDirection` fallback) or `view` are `nil`. Else, takes the current `velocity(in:)` and simplfies it down to the specified `direction`. For example, if `direction` is `.down`, and the velocity is `CGPoint(x: 12.0, y: 16.0)`, the function returns `16.0`.
     */
    
    public func velocity(in direction: Direction? = nil) -> CGFloat {
        guard let direction = direction ?? initialDirection, let view = view else {
            return 0.0
        }
        
        return velocity(in: view).magnitude(inDirection: direction)
    }

}

// MARK: - Private helpers

private extension CGPoint {
    
    func magnitude(inDirection direction: DirectedPanGestureRecognizer.Direction) -> CGFloat {
        switch direction {
        case .up:
            return -y
        case .left:
            return -x
        case .down:
            return +y
        case .right:
            return +x
        }
    }
    
}

private extension CGRect {
    
    func magnitude(inDirection direction: DirectedPanGestureRecognizer.Direction) -> CGFloat {
        switch direction {
        case .up, .down:
            return height
        case .left, .right:
            return width
        }
    }
    
}
