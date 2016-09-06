//
//  RxLocationManager.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

public final class RxLocationManager {

    public static func standardLocationTracker() -> RxLocationTracker {
        return RxLocationTracker()
    }

}
