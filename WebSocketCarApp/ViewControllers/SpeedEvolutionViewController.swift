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

enum ShapeLaper: String {
    case shapeLayerGreen
    case shapeLayerYellow
    case shapeLayerRed
    case trackLayer
}

class SpeedEvolutionViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
        
    private let disposeBag = DisposeBag()
    private let shapeLayers: [String: CAShapeLayer] = ["shapeLayerGreen": CAShapeLayer(), "shapeLayerYellow": CAShapeLayer(), "shapeLayerRed": CAShapeLayer(), "trackLayer": CAShapeLayer()]
    private let shapeLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    private let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    private var percentage: Float = 0.0

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
    
    fileprivate func makeShapeLayer(_ name: ShapeLaper, color: CGColor, strokeEnd: CGFloat, rotate: CGFloat) {
        shapeLayers[name.rawValue]?.path = circularPath.cgPath
        shapeLayers[name.rawValue]?.strokeColor = color
        shapeLayers[name.rawValue]?.lineWidth = 10
        shapeLayers[name.rawValue]?.fillColor = UIColor.clear.cgColor
        shapeLayers[name.rawValue]?.lineCap = kCALineCapRound
        shapeLayers[name.rawValue]?.position = view.center
        
        shapeLayers[name.rawValue]?.transform = CATransform3DMakeRotation(rotate, 0, 0, 1)
        shapeLayers[name.rawValue]?.strokeEnd = strokeEnd
        
        view.layer.addSublayer(shapeLayers[name.rawValue]!)
    }
    
    fileprivate func animShapeLayer() {
        shapeLayers[ShapeLaper.shapeLayerRed.rawValue]?.removeFromSuperlayer()
        shapeLayers[ShapeLaper.shapeLayerYellow.rawValue]?.removeFromSuperlayer()
        basicAnimation.duration = 0.5
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        let percent = Int(percentage*100)
        
        switch percent {
        case 76...100:
            makeShapeLayer(.shapeLayerRed, color: UIColor.red.cgColor, strokeEnd: 0.0, rotate: CGFloat.pi)
            basicAnimation.toValue = percentage-0.75
            shapeLayers[ShapeLaper.shapeLayerRed.rawValue]?.add(basicAnimation, forKey: "Speed_Circle_Animation")
            shapeLayers[ShapeLaper.shapeLayerRed.rawValue]?.strokeEnd = CGFloat(percentage)-0.75
            fallthrough
        case 51...75:
            makeShapeLayer(.shapeLayerYellow, color: UIColor.orange.cgColor, strokeEnd: 0.0, rotate: CGFloat.pi/2)
            basicAnimation.toValue =  percent > 75 ? 0.25 : CGFloat(percentage)-0.5
            shapeLayers[ShapeLaper.shapeLayerYellow.rawValue]?.add(basicAnimation, forKey: "Speed_Circle_Animation")
            shapeLayers[ShapeLaper.shapeLayerYellow.rawValue]?.strokeEnd = percent > 75 ? 0.25 : CGFloat(percentage)-0.5
            fallthrough
        case 0...50:
            makeShapeLayer(.shapeLayerGreen, color: UIColor.green.cgColor, strokeEnd: 0.0, rotate: -CGFloat.pi/2)
            basicAnimation.toValue = percent > 50 ? 0.5 : CGFloat(percentage)
            shapeLayers[ShapeLaper.shapeLayerGreen.rawValue]?.add(basicAnimation, forKey: "Speed_Circle_Animation")
            shapeLayers[ShapeLaper.shapeLayerGreen.rawValue]?.strokeEnd = percent > 50 ? 0.5 : CGFloat(percentage)
        default:
            print("Doing nothing")
        }
    }
    
    fileprivate func makeCircularProgessBar() {
        makeShapeLayer(.trackLayer, color: UIColor.lightGray.cgColor, strokeEnd: 1.0, rotate: -CGFloat.pi/2)
        view.layer.addSublayer(shapeLayers[ShapeLaper.trackLayer.rawValue]!)
        makeShapeLayer(.shapeLayerGreen, color: UIColor.lightGray.cgColor, strokeEnd: 0.0, rotate: -CGFloat.pi/2)
        view.layer.addSublayer(shapeLayers[ShapeLaper.shapeLayerGreen.rawValue]!)
    }
    
    fileprivate func removeShapeLayers() {
        for shapeLayer in shapeLayers {
            shapeLayer.value.removeFromSuperlayer()
        }
    }
    
    @objc private func rotated() {
        removeShapeLayers()
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
            guard let mySpeedEvolution = speedEvolution else { return }
            self.percentage =  mySpeedEvolution.CurrentSpeed / Float(mySpeedEvolution.SpeedMax)
            self.animShapeLayer()
            self.percentageLabel.text = "\(Int(self.percentage*100)) %"
            self.speedLabel.text = "\(mySpeedEvolution.CurrentSpeed) / \(mySpeedEvolution.SpeedMax)"
        }).disposed(by: disposeBag)
    }
}
