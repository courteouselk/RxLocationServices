//
//  CLAuthorizationStatus.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 08/09/2016.
//  Copyright © 2016 northernForest. All rights reserved.
//

import CoreLocation

extension CLAuthorizationStatus: CustomStringConvertible {

    public var description: String {
        switch self {

        case .notDetermined:
            return "Not determined"

        case .restricted:
            return "Restricted"

        case .denied:
            return "Denied"

        case .authorizedWhenInUse:
            return "Authorized when in use"

        case .authorizedAlways:
            return "Authorized always"

        }
    }

}
