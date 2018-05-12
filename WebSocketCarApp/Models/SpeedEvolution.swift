//
//  SpeedEvolution.swift
//  WebSocketCarApp
//
//  Created by Stephane Darcy SIMO MBA on 12/05/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import Foundation

class SpeedEvolution {
    var Brand: String
    var Name: String
    var SpeedMax: Int
    var Cv: Int
    var CurrentSpeed: Float
    
    init?(dictionary: [String: Any]) {
        guard let m_Brand = dictionary["Brand"] as? String,
        let m_Name = dictionary["Name"] as? String,
        let m_SpeedMax = dictionary["SpeedMax"] as? Int,
        let m_Cv = dictionary["Cv"] as? Int,
            let m_CurrentSpeed = dictionary["CurrentSpeed"] as? NSNumber else {
                return nil
        }
        Brand = m_Brand
        Name = m_Name
        SpeedMax = m_SpeedMax
        Cv = m_Cv
        CurrentSpeed = m_CurrentSpeed.floatValue
    }
}
