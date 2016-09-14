//
//  RxLocationTracker+Failure.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 14/09/2016.
//  Copyright © 2016 northernForest. All rights reserved.
//

extension RxLocationTracker {

    enum Failure: Error {

        /// App is denied to use location services. Please abort your attempt to use them.
        case locationServicesDenied

        /// Location services are restricted. Please abort your attempt to use them.
        case locationServicesRestricted

        /// App is authorized to use location services when in use only.
        case locationServicesAuthorizedWhenInUseOnly

        /// Standard location services are not available.
        case standardLocationServicesUnavailable

        /// Deferred location services are not available.
        case deferredLocationServicesUnavailable

        /// Significant location change services are not available.
        case significantLocationChangeServicesUnavailable
        
    }
    
}

// MARK:

extension RxLocationTracker.Failure: CustomStringConvertible {

    var description: String {
        switch self {

        case .locationServicesDenied:
            return "App is denied to use location services. Please abort your attempt to use them."

        case .locationServicesRestricted:
            return "Location services are restricted. Please abort your attempt to use them."

        case .locationServicesAuthorizedWhenInUseOnly:
            return "App is authorized to use location services when in use only."

        case .standardLocationServicesUnavailable:
            return "Standard location services are not available."

        case .deferredLocationServicesUnavailable:
            return "Deferred location services are not available."

        case .significantLocationChangeServicesUnavailable:
            return "Significant location change services are not available."

        }
    }

}
