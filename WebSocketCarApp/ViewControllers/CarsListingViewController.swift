//
//  ViewController.swift
//  WebSocketCarApp
//
//  Created by Stephane Darcy SIMO MBA on 10/05/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Starscream
import RxSwift
import RxCocoa

class CarsListingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var socket: WebSocket!
    
    static var speedEvolution = BehaviorRelay<SpeedEvolution?>(value: nil)
    var indexPath: IndexPath?
    var speedEvolutionVC: SpeedEvolutionViewController!
    var bioCars = BehaviorRelay<[BioCar]>(value: [])
    
    private let server_url = "ws://pbbouachour.fr:8080/openSocket"
    private let CellID = "Cell"
    private let SpeedEvolutionViewControllerID = "SpeedEvolutionViewController"
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Listing Cars"
        socket = WebSocket(url: URL(string: server_url)!)
        socket.delegate = self
        socket.connect()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellID)
        
        setUpRefreshControl()

        bioCars.bind(to: tableView.rx.items(cellIdentifier: CellID, cellType: UITableViewCell.self)) { row, bioCar, cell in
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell.textLabel?.text = bioCar.Name+" "+bioCar.Brand
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            if self.indexPath != nil { self.sendData(Type: "stop", UserToken: 42) }

            self.indexPath = indexPath
            self.sendData(Type: "start", UserToken: 42, Name: self.bioCars.value[indexPath.row].Name)
            self.speedEvolutionVC = self.storyboard?.instantiateViewController(withIdentifier: self.SpeedEvolutionViewControllerID) as! SpeedEvolutionViewController
            self.navigationController?.pushViewController(self.speedEvolutionVC, animated: true)
        }).disposed(by: disposeBag)
        
    }
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    private func setUpRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "refresh List")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refresh () {
        self.sendData(Type: "infos", UserToken: 42)
    }
}
