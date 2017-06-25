//
//  ViewController.swift
//  DirectedPanDemo
//
//  Created by Daniel Clelland on 11/04/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var panGestureRecognizer: DirectedPanGestureRecognizer!
    
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var velocityLabel: UILabel!
    
    @IBOutlet weak var arrowLabel: UILabel!
    
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var minimumTranslationLabel: UILabel!
    @IBOutlet weak var minimumTranslationSlider: UISlider!
    
    @IBOutlet weak var minimumVelocityLabel: UILabel!
    @IBOutlet weak var minimumVelocitySlider: UISlider!
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    // MARK: View state
    
    func updateView() {
        let currentDirection = direction(forIndex: directionSegmentedControl.selectedSegmentIndex)!
        
        let translationText = String(format: "%.2f", panGestureRecognizer.translation())
        let velocityText = String(format: "%.2f", panGestureRecognizer.velocity())
        
        translationLabel.text = "Translation: " + translationText
        velocityLabel.text = "Velocity: " + velocityText
        
        let translationColor = panGestureRecognizer.translation() < panGestureRecognizer.minimumTranslation ? UIColor.red : UIColor.green
        let velocityColor = panGestureRecognizer.velocity() < panGestureRecognizer.minimumVelocity ? UIColor.red : UIColor.green
        
        translationLabel.backgroundColor = translationColor
        velocityLabel.backgroundColor = velocityColor
        
        let arrowText = arrow(forDirection: currentDirection)
        
        arrowLabel.text = arrowText
        
        let minimumTranslationText = String(format: "%.2f", panGestureRecognizer.minimumTranslation)
        let minimumVelocityText = String(format: "%.2f", panGestureRecognizer.minimumVelocity)
        
        minimumTranslationLabel.text = "Minimum translation: " + minimumTranslationText
        minimumVelocityLabel.text = "Minimum velocity: " + minimumVelocityText
    }
    
    // MARK: Actions
    
    @IBAction func directionSegmentedControlDidChangeValue(_ segmentedControl: UISegmentedControl) {
        updateView()
    }
    
    @IBAction func minimumTranslationSliderDidChangeValue(_ slider: UISlider) {
        panGestureRecognizer.minimumTranslation = minimumTranslation(forValue: slider.value)
        updateView()
    }
    
    @IBAction func minimumVelocitySliderDidChangeValue(_ slider: UISlider) {
        panGestureRecognizer.minimumVelocity = minimumVelocity(forValue: slider.value)
        updateView()
    }

}

// MARK: - Gesture recognizer delegate

extension ViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case let panGestureRecognizer as DirectedPanGestureRecognizer where panGestureRecognizer == self.panGestureRecognizer:
            return panGestureRecognizer.direction == direction(forIndex: directionSegmentedControl.selectedSegmentIndex)!
        default:
            return true
        }
    }

}

// MARK: - Directed pan gesture recognizer delegate

extension ViewController: DirectedPanGestureRecognizerDelegate {
    
    func directedPanGestureRecognizer(didStart gestureRecognizer: DirectedPanGestureRecognizer) {
        arrowLabel.backgroundColor = .clear
        updateView()
    }
    
    func directedPanGestureRecognizer(didUpdate gestureRecognizer: DirectedPanGestureRecognizer) {
        arrowLabel.backgroundColor = .clear
        updateView()
    }
    
    func directedPanGestureRecognizer(didCancel gestureRecognizer: DirectedPanGestureRecognizer) {
        arrowLabel.backgroundColor = .red
        updateView()
    }
    
    func directedPanGestureRecognizer(didFinish gestureRecognizer: DirectedPanGestureRecognizer) {
        arrowLabel.backgroundColor = .green
        updateView()
    }
    
}

// MARK: - Private helpers

private extension ViewController {
    
    func direction(forIndex index: Int) -> DirectedPanGestureRecognizer.Direction? {
        switch index {
        case 0:
            return .up
        case 1:
            return .left
        case 2:
            return .down
        case 3:
            return .right
        default:
            return nil
        }
    }
    
    func minimumTranslation(forValue value: Float) -> CGFloat {
        return CGFloat(value) * view.frame.width
    }
    
    func minimumVelocity(forValue value: Float) -> CGFloat {
        return CGFloat(value) * view.frame.width
    }
    
    func arrow(forDirection direction: DirectedPanGestureRecognizer.Direction) -> String {
        switch direction {
        case .up:
            return "↑"
        case .left:
            return "←"
        case .down:
            return "↓"
        case .right:
            return "→"
        }
    }

}
