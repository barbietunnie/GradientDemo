//
//  ViewController.swift
//  GradientDemo
//
//  Created by Babatunde Adeyemi on 8/12/16.
//  Copyright © 2016 Babatunde Adeyemi. All rights reserved.
//
// GradientDemo: Dynamically generating gradients to use
//               as the background of a view
//
// Supported by: http://www.appcoda.com/cagradientlayer/

import UIKit

class ViewController: UIViewController {
    
    var gradientLayer: CAGradientLayer!
    var colorsets = [[CGColor]]()
    var currentColorSet: Int!
    
    enum PanDirections: Int {
        case Right
        case Left
        case Bottom
        case Top
        case TopLeftToBottomRight
        case TopRightToBottomLeft
        case BottomLeftToTopRight
        case BottomRightToTopLeft
    }
    
    var panDirection: PanDirections!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createColorSets()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        let twoFingerTapgestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerTapGesture))
        twoFingerTapgestureRecognizer.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(twoFingerTapgestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
//        gradientLayer.colors = [UIColor.redColor().CGColor, UIColor.yellowColor().CGColor]
        
//        gradientLayer.colors = [UIColor.redColor().CGColor, UIColor.orangeColor().CGColor, UIColor.blueColor().CGColor, UIColor.magentaColor().CGColor, UIColor.yellowColor().CGColor]
        
        gradientLayer.locations = [0.0, 0.35]
        gradientLayer.colors = colorsets[currentColorSet]
        
//        gradientLayer.startPoint = CGPointMake(0.0, 0.5)
//        gradientLayer.endPoint = CGPointMake(1.0, 0.5)
        
        
        self.view.layer.addSublayer(gradientLayer)
    }
    
    func createColorSets() {
        colorsets.append([UIColor.redColor().CGColor, UIColor.yellowColor().CGColor])
        colorsets.append([UIColor.greenColor().CGColor, UIColor.magentaColor().CGColor])
        colorsets.append([UIColor.grayColor().CGColor, UIColor.lightGrayColor().CGColor])
        
        currentColorSet = 0
    }

    func handleGesture(gestureRecognizer: UITapGestureRecognizer) {
        if currentColorSet < colorsets.count - 1 {
            currentColorSet! += 1
        } else {
            currentColorSet = 0
        }
        
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.duration = 2.0
        colorChangeAnimation.toValue = colorsets[currentColorSet]
        colorChangeAnimation.fillMode = kCAFillModeForwards
        colorChangeAnimation.removedOnCompletion = false
        gradientLayer.addAnimation(colorChangeAnimation, forKey: "colorChange")
        
        colorChangeAnimation.delegate = self
        
//        gradientLayer.addAnimation(colorChangeAnimation, forKey: "colorChange")
    }
    
    func handleTwoFingerTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        let secondColorLocation = arc4random_uniform(100)
        let firstColorLocation = arc4random_uniform(secondColorLocation - 1)
        
        gradientLayer.locations = [NSNumber(double: Double(firstColorLocation)/100.0), NSNumber(double: Double(secondColorLocation) / 100.0)]
        
        print(gradientLayer.locations)
    }
    
    func handlePanGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        let velocity = gestureRecognizer.velocityInView(self.view)
        
        if gestureRecognizer.state == UIGestureRecognizerState.Changed {
            if velocity.x > 300.0 {
                // In this case the direction is generally towards Right.
                // Below are specific cases regarding the vertical movement of the gesture.
                
                if velocity.y > 300.0 {
                    // Movement from Top-Left to Bottom-Right.
                    panDirection = PanDirections.TopLeftToBottomRight
                } else if velocity.y < 300.0 {
                    // Movement from Bottom-Left to Top-Right.
                    panDirection = PanDirections.BottomLeftToTopRight
                } else {
                    // Movement towards Right.
                    panDirection = PanDirections.Right
                }
            } else if velocity.x < -300.0 {
                // In this case the direction is generally towards Left.
                // Below are specific cases regarding the vertical movement of the gesture.
                
                if velocity.y > 300.0 {
                    // Movement from Top-Right to Bottom-Left.
                    panDirection = PanDirections.TopRightToBottomLeft
                }
                else if velocity.y < -300.0 {
                    // Movement from Bottom-Right to Top-Left.
                    panDirection = PanDirections.BottomRightToTopLeft
                }
                else {
                    // Movement towards Left.
                    panDirection = PanDirections.Left
                }
            } else {
                // In this case the movement is mostly vertical (towards bottom or top).
                
                if velocity.y > 300.0 {
                    // Movement towards Bottom.
                    panDirection = PanDirections.Bottom
                }
                else if velocity.y < -300.0 {
                    // Movement towards Top.
                    panDirection = PanDirections.Top
                }
                else {
                    // Do nothing.
                    panDirection = nil
                }

            }
        } else if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            changeGradientDirection()
        }
    }
    
    func changeGradientDirection() {
        if panDirection != nil {
            switch panDirection.rawValue {
            case PanDirections.Right.rawValue:
                gradientLayer.startPoint = CGPointMake(0.0, 0.5)
                gradientLayer.endPoint = CGPointMake(1.0, 0.5)
            
            case PanDirections.Left.rawValue:
                gradientLayer.startPoint = CGPointMake(1.0, 0.5)
                gradientLayer.endPoint = CGPointMake(0.0, 0.5)
                
            case PanDirections.Bottom.rawValue:
                gradientLayer.startPoint = CGPointMake(0.5, 0.0)
                gradientLayer.endPoint = CGPointMake(0.5, 1.0)
                
            case PanDirections.Top.rawValue:
                gradientLayer.startPoint = CGPointMake(0.5, 1.0)
                gradientLayer.endPoint = CGPointMake(0.5, 0.0)
                
            case PanDirections.TopLeftToBottomRight.rawValue:
                gradientLayer.startPoint = CGPointMake(0.0, 0.0)
                gradientLayer.endPoint = CGPointMake(1.0, 1.0)
                
            case PanDirections.TopRightToBottomLeft.rawValue:
                gradientLayer.startPoint = CGPointMake(1.0, 0.0)
                gradientLayer.endPoint = CGPointMake(0.0, 1.0)
                
            case PanDirections.BottomLeftToTopRight.rawValue:
                gradientLayer.startPoint = CGPointMake(0.0, 1.0)
                gradientLayer.endPoint = CGPointMake(1.0, 0.0)
                
            default:
                gradientLayer.startPoint = CGPointMake(1.0, 1.0)
                gradientLayer.endPoint = CGPointMake(0.0, 0.0)
            }
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorsets[currentColorSet]
        }
    }
}

