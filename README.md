# DirectedPanGestureRecognizer

DirectedPanGestureRecognizer is a UIPanGestureRecognizer subclass providing a richer API for working with pan gestures in Swift 3.

It's based on my older [CXSwipeGestureRecognizer](https://github.com/dclelland/CXSwipeGestureRecognizer) library. It doesn't strictly deprecate that project – while it's mostly just a straight rewrite in Swift, some of the more opinionated features have been removed.

#### Installation:

```ruby
pod 'DirectedPanGestureRecognizer', '~> 1.0'
```

#### Usage:

```swift
let gestureRecognizer = DirectedPanGestureRecognizer()
gestureRecognizer.delegate = self
view.addGestureRecognizer(gestureRecognizer)
```

### Features:

✓ Keeps track of the initial state of the gesture:

```swift
if (gestureRecognizer.initialDirection == .up) {
    if (gestureRecognizer.direction == .down) {
        print("Gesture recognizer started swiping upwards and then changed direction")
    }
}
```

✓ Enforce the gesture's starting direction:

```swift
func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    switch gestureRecognizer {
    case let panGestureRecognizer as DirectedPanGestureRecognizer where panGestureRecognizer == self.panGestureRecognizer:
        return panGestureRecognizer.direction == .left
    default:
        return true
    }
}
```

✓ Delegate protocol methods for `start`, `update`, `cancel`, and `finish` events:

```swift
func directedPanGestureRecognizer(didStart gestureRecognizer: DirectedPanGestureRecognizer) {
    print("Gesture recognizer started")
}

func directedPanGestureRecognizer(didUpdate gestureRecognizer: DirectedPanGestureRecognizer) {
    print("Gesture recognizer updated")
}

func directedPanGestureRecognizer(didCancel gestureRecognizer: DirectedPanGestureRecognizer) {
    print("Gesture recognizer cancelled")
}

func directedPanGestureRecognizer(didFinish gestureRecognizer: DirectedPanGestureRecognizer) {
    print("Gesture recognizer finished")
}
```

✓ Convenience methods for `location`, `direction`, `translation`, and `velocity`:

```swift
let location = gestureRecognizer.location // CGPoint?
let direction = gestureRecognizer.direction // DirectedPanGestureRecognizer.Direction?
let translation = gestureRecognizer.translation(inDirection: .right) // CGFloat
let velocity = gestureRecognizer.velocity(inDirection: .right) // CGFloat
```

✓ `IBDesignable` parameters for enforcing a minimum translation and velocity:

```swift
gestureRecognizer.minimumTranslation = 64.0
gestureRecognizer.minimumVelocity = 256.0
```
