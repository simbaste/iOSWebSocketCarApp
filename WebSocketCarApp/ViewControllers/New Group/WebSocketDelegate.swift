//
//  WebSocketDelegate.swift
//  WebSocketCarApp
//
//  Created by Stephane Darcy SIMO MBA on 13/05/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Starscream

extension CarsListingViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("Opend")
        sendData(Type: "infos", UserToken: 42)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Some error \(String(describing: error))")
        tableView.refreshControl?.endRefreshing()
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: .utf8) {
            do {
                guard let receivedBioCars = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] else {
                    guard let receivedSpeedEvolution = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                        return
                    }
                    let rcvSpeedEvlts = [receivedSpeedEvolution]
                    CarsListingViewController.speedEvolution.accept(rcvSpeedEvlts.compactMap(SpeedEvolution.init).first)
                    speedEvolutionVC.titleLabel.text = (receivedSpeedEvolution["Name"] as? String)!+" "+(receivedSpeedEvolution["Brand"] as? String)!
                    return
                }
                bioCars.accept(receivedBioCars.compactMap(BioCar.init))
            } catch let error {
                print("Error parsing json: \(error)")
                tableView.refreshControl?.endRefreshing()
            }
        }
        tableView.refreshControl?.endRefreshing()
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Receive Data \(data)")
    }
    
    func sendData(Type: String, UserToken: Int, Name: String? = nil) {
        var json = [String: Any]()
        
        json["Type"] = Type
        json["UserToken"] = UserToken
        if Name != nil {
            var Payload = [String: Any]()
            Payload["Name"] = Name
            json["Payload"] = Payload
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            socket.write(data: jsonData)
        } catch let error {
            print("Couldn't create json data: \(error)")
            tableView.refreshControl?.endRefreshing()
        }
    }
}
