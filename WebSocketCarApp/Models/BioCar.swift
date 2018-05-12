//
//  BioCar.swift
//  WebSocketCarApp
//
//  Created by Stephane Darcy SIMO MBA on 12/05/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import Foundation

struct BioCar {
    var SpeedMax: Int
    var CurrentSpeed: Int
    var Name: String
    var Brand: String
    var Cv: Int
    
    init?(dictionary: [String: Any]) {
        guard let m_SpeedMax = dictionary["SpeedMax"] as? Int,
        let m_CurrentSpeed = dictionary["CurrentSpeed"] as? Int,
        let m_Name = dictionary["Name"] as? String,
        let m_Brand = dictionary["Brand"] as? String,
        let m_Cv = dictionary["Cv"] as? Int else {
            return nil
        }
        
        SpeedMax = m_SpeedMax
        CurrentSpeed = m_CurrentSpeed
        Name = m_Name
        Brand = m_Brand
        Cv = m_Cv
    }
}
