////
////  AdmobManager.swift
////  LifeLog
////
////  Created by Genki on 1/9/24.
////
//
import GoogleMobileAds
import UserMessagingPlatform
import AppTrackingTransparency

class AdmobManager {
    @Published var trackingAuthorized: Bool?

    func checkTrackingAuthorizationStatus() {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .notDetermined:
            requestTrackingAuthorization()
        case .restricted:
            updateTrackingAuthorizationStatus(false)
            print("restricted")
        case .denied:
            updateTrackingAuthorizationStatus(false)
            print("denied")
        case .authorized:
            updateTrackingAuthorizationStatus(true)
            print("authorized")
        @unknown default:
            fatalError()
        }
    }

    func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                self.updateTrackingAuthorizationStatus(false)
                print("restricted")
            case .denied:
                self.updateTrackingAuthorizationStatus(false)
                print("denied")
            case .authorized:
                self.updateTrackingAuthorizationStatus(true)
                print("authorized")
            @unknown default:
                fatalError()
            }
        }
    }

    func updateTrackingAuthorizationStatus(_ authorized: Bool) {
        GADMobileAds.sharedInstance().start { _ in
            self.trackingAuthorized = authorized
        }
    }
}
