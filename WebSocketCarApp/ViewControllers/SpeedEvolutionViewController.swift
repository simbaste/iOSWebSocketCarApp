//
//  SpeedEvolutionViewController.swift
//  WebSocketCarApp
//
//  Created by Stephane Darcy SIMO MBA on 12/05/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SpeedEvolutionViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
        
    private let disposeBag = DisposeBag()
    private let shapeLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    private let speedLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0 / 0"
        label.textAlignment = .center
        label.font = UIFont(name: "Times New Roman", size: 17)
        return label
    }()
    
    fileprivate func makeCircularProgessBar() {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = kCALineCapRound
        trackLayer.position = view.center
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.brown.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.position = view.center
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    @objc private func rotated() {
        shapeLayer.removeFromSuperlayer()
        trackLayer.removeFromSuperlayer()
        percentageLabel.removeFromSuperview()
        speedLabel.removeFromSuperview()
        makeCircularProgessBar()
        addSomeText()
    }
    
    fileprivate func addSomeText() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        
        view.addSubview(speedLabel)
        speedLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        speedLabel.center = CGPoint(x: view.center.x, y: view.center.y+30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSomeText()

        makeCircularProgessBar()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        CarsListingViewController.speedEvolution.subscribe(onNext: { speedEvolution in
            
            guard let mySpeedEvolution = speedEvolution else {
                return
            }
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.duration = 0.5
            basicAnimation.fillMode = kCAFillModeForwards
            basicAnimation.isRemovedOnCompletion = false
            
            let percentage =  mySpeedEvolution.CurrentSpeed / Float(mySpeedEvolution.SpeedMax)
            basicAnimation.toValue = percentage
            self.shapeLayer.add(basicAnimation, forKey: "Speed_Circle_Animation")
            self.shapeLayer.strokeEnd = CGFloat(percentage)
            self.percentageLabel.text = "\(Int(percentage*100)) %"
            self.speedLabel.text = "\(mySpeedEvolution.CurrentSpeed) / \(mySpeedEvolution.SpeedMax)"
        }).disposed(by: disposeBag)
    }
}
