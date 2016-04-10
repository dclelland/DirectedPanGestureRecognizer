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
@objc protocol DirectedPanGestureRecognizerDelegate: UIGestureRecognizerDelegate {
    
    /// Called when the pan gesture recognizer starts.
    optional func directedPanGestureRecognizerDidStart(gestureRecognizer: DirectedPanGestureRecognizer)
    
    /// Called when the pan gesture recognizer updates.
    optional func directedPanGestureRecognizerDidUpdate(gestureRecognizer: DirectedPanGestureRecognizer)
    
    /// Called when the pan gesture recognizer cancels. A pan gesture recognizer may cancel if its translation or velocity in `initialDirection` is less than the value of `minimumTranslation` or `minimumVelocity`, respectively.
    optional func directedPanGestureRecognizerDidCancel(gestureRecognizer: DirectedPanGestureRecognizer)
    
    /// Called when the pan gesture recognizer finishes. A pan gesture recognizer may finish if its translation and velocity in `initialDirection` are greater than or equal to the value of `minimumTranslation` or `minimumVelocity`, respectively.
    optional func directedPanGestureRecognizerDidFinish(gestureRecognizer: DirectedPanGestureRecognizer)
    
}

class DirectedPanGestureRecognizer: UIPanGestureRecognizer {
    
    /// The pan gesture recognizer's direction. Also used to calculate attributes for a given direction.
    enum Direction {
        /// The pan gesture recognizer's touches move upwards.
        case Up
        /// The pan gesture recognizer's touches move leftwards.
        case Left
        /// The pan gesture recognizer's touches move downwards.
        case Down
        /// The pan gesture recognizer's touches move rightwards.
        case Right
    }
    
    // MARK: Configuration
    
    /// Minimum translation (in `initialDirection`) required for the gesture to finish. Defaults to `0.0`.
    @IBInspectable var minimumTranslation: CGFloat = 0.0
    
    /// Minimum velocity (in `initialDirection`) required for the gesture to finish. Defaults to `0.0`.
    @IBInspectable var minimumVelocity: CGFloat = 0.0
    
    // MARK: Internal variables
    
    /// The current location in `view` when the pan gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    private(set) var initialLocation: CGPoint?
    
    /// The current direction in `view` when the pan gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    private(set) var initialDirection: Direction?
    
    // MARK: Delegation
    
    override var delegate: UIGestureRecognizerDelegate? {
        didSet {
            self.addTarget(self, action: "onPan")
        }
    }
    
    private var directedPanDelegate: DirectedPanGestureRecognizerDelegate? {
        return delegate as? DirectedPanGestureRecognizerDelegate
    }
    
    // MARK: Initialization
    
    /// Initialize the pan gesture recognizer with no target or action set.
    convenience init() {
        self.init(target: nil, action: nil)
    }
    
    // MARK: Overrides
    
    override func reset() {
        super.reset()
        
        initialLocation = nil
        initialDirection = nil
    }
    
    // MARK: Actions
    
    /// Called when the pan gesture recognizer updates. Final function which should otherwise be private, as this method's selector is added as a target when the `delegate` is set, and selectors require their methods to be public.
    final func onPan() {
        if (state == .Began) {
            initialLocation = location
            initialDirection = direction
        }
    
        switch state {
        case .Began:
            directedPanDelegate?.directedPanGestureRecognizerDidStart?(self)
        case .Changed:
            directedPanDelegate?.directedPanGestureRecognizerDidUpdate?(self)
        case .Cancelled:
            directedPanDelegate?.directedPanGestureRecognizerDidCancel?(self)
        case .Ended where shouldCancel():
            directedPanDelegate?.directedPanGestureRecognizerDidCancel?(self)
        case .Ended:
            directedPanDelegate?.directedPanGestureRecognizerDidFinish?(self)
        default:
            break
        }
    }
    
    // MARK: Cancellation
    
    private func shouldCancel() -> Bool {
        return translation() < minimumTranslation || velocity() < minimumVelocity
    }

}

// MARK: - Dynamic variables

extension DirectedPanGestureRecognizer {
    
    /// The pan gesture recognizer's current location in `view`, calculated using `locationInView()`. Returns `nil` if `view` is `nil`.
    var location: CGPoint? {
        guard let view = view else {
            return nil
        }
        
        return locationInView(view)
    }
    
    /// The pan gesture recognizer's current direction in `view`, calculated using `translationInView()`. Returns `nil` if `view` is `nil`.
    var direction: Direction? {
        guard let view = view else {
            return nil
        }
        
        let translation = translationInView(view)
        
        if (translation == CGPoint.zero) {
            return nil
        } else if (fabs(translation.x) < fabs(translation.y)) {
            return translation.y > 0.0 ? .Down : .Up
        } else {
            return translation.x > 0.0 ? .Right : .Left
        }
    }
    
}

// MARK: - Directional helpers

extension DirectedPanGestureRecognizer {
    
    /**
     The pan gesture recognizer's current translation in `view`, simplified to a linear value in a given direction.
     
     - parameter direction: The direction. Defaults to `nil`, in which case `initialDirection` is used.
     
     - returns: Returns `0.0` if either `direction` (or the `initialDirection` fallback) or `view` are `nil`. Else, takes the current `translationInView()` and simplfies it down to the specified `direction`. For example, if `direction` is `.Left`, and the translation is `CGPoint(x: 3.0, y: 4.0)`, the function returns `3.0`.
     */
    
    func translation(inDirection direction: Direction? = nil) -> CGFloat {
        guard let direction = direction ?? initialDirection, view = view else {
            return 0.0
        }
        
        return translationInView(view).magnitude(inDirection: direction)
    }
    
    /**
     The pan gesture recognizer's current velocity in `view`, simplified to a linear value in a given direction.
     
     - parameter direction: The direction. Defaults to `nil`, in which case `initialDirection` is used.
     
     - returns: Returns `0.0` if either `direction` (or the `initialDirection` fallback) or `view` are `nil`. Else, takes the current `velocityInView()` and simplfies it down to the specified `direction`. For example, if `direction` is `.Down`, and the velocity is `CGPoint(x: 12.0, y: 16.0)`, the function returns `16.0`.
     */
    
    func velocity(inDirection direction: Direction? = nil) -> CGFloat {
        guard let direction = direction ?? initialDirection, view = view else {
            return 0.0
        }
        
        return velocityInView(view).magnitude(inDirection: direction)
    }

}

// MARK: - Private helpers

private extension CGPoint {
    
    func magnitude(inDirection direction: DirectedPanGestureRecognizer.Direction) -> CGFloat {
        switch direction {
        case .Up:
            return -y
        case .Left:
            return -x
        case .Down:
            return +y
        case .Right:
            return +x
        }
    }
    
}

private extension CGRect {
    
    func magnitude(inDirection direction: DirectedPanGestureRecognizer.Direction) -> CGFloat {
        switch direction {
        case .Up, .Down:
            return height
        case .Left, .Right:
            return width
        }
    }
    
}
