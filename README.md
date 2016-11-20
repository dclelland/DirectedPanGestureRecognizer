# DirectedPanGestureRecognizer

DirectedPanGestureRecognizer is a UIPanGestureRecognizer subclass providing a richer API for working with pan gestures.

It's based on my older [CXSwipeGestureRecognizer](https://github.com/dclelland/CXSwipeGestureRecognizer) library. It doesn't strictly deprecate that project – while it's mostly just a straight rewrite in Swift, some of the more opinionated features have been removed.

#### Installation:

```ruby
pod 'DirectedPanGestureRecognizer', '~> 0.2'
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
if (gestureRecognizer.initialDirection == .Up) {
    if (gestureRecognizer.direction == .Down) {
        print("Gesture recognizer started swiping upwards and then changed direction")
    }
}
```

✓ Enforce the gesture's starting direction:

```swift
func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    switch gestureRecognizer {
    case let panGestureRecognizer as DirectedPanGestureRecognizer where panGestureRecognizer == self.panGestureRecognizer:
        return panGestureRecognizer.direction == .Left
    default:
        return true
    }
}
```

✓ Delegate protocol methods for `start`, `update`, `cancel`, and `finish` events:

```swift
func directedPanGestureRecognizerDidStart(gestureRecognizer: DirectedPanGestureRecognizer) {
    print("Gesture recognizer started")
}

func directedPanGestureRecognizerDidUpdate(gestureRecognizer: DirectedPanGestureRecognizer) {
    print("Gesture recognizer updated")
}

func directedPanGestureRecognizerDidCancel(gestureRecognizer: DirectedPanGestureRecognizer) {
    print("Gesture recognizer cancelled")
}

func directedPanGestureRecognizerDidFinish(gestureRecognizer: DirectedPanGestureRecognizer) {
    print("Gesture recognizer finished")
}
```

✓ Convenience methods for `location`, `direction`, `translation`, and `velocity`:

```swift
let location = gestureRecognizer.location // CGPoint?
let direction = gestureRecognizer.direction // DirectedPanGestureRecognizer.Direction?
let translation = gestureRecognizer.translation(inDirection: .Right) // CGFloat
let velocity = gestureRecognizer.velocity(inDirection: .Right) // CGFloat
```

✓ `IBDesignable` parameters for enforcing a minimum translation and velocity:

```swift
gestureRecognizer.minimumTranslation = 64.0
gestureRecognizer.minimumVelocity = 256.0
```

### Todo:

- Make GIF preview
- Publish to Cocoapods
- Publish to Carthage
- Publish to Cocoa controls
