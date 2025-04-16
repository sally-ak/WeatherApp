//
//

import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    let manager = CLLocationManager()
    var completion: ((CLLocation) -> Void)?
    var name = ""
    var lat = 0.00
    var lon = 0.00
    public func getUserLocation(completion: @escaping ((CLLocation) -> Void)){
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    public func resolveLocationName(with location: CLLocation, completion: @escaping ((String?) -> Void)){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current){placemarks,
            error in
            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            print(place)
            if let locality = place.locality {
                self.name = locality
            }
            print(self.name)
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            completion(self.name)
        }
    }
    public func resolveLocationLatitude(with location: CLLocation, completion: @escaping ((Float?) -> Void)){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current){placemarks,
            error in
            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            print(place)
            if let locality = place.location?.coordinate.latitude {
                self.lat = locality
            }
            print(self.lat)
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            completion(Float(self.lat))
        }
    }
    public func resolveLocationLongitude(with location: CLLocation, completion: @escaping ((Float?) -> Void)){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current){placemarks,
            error in
            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            print(place)
            if let locality = place.location?.coordinate.longitude {
                self.lon = locality
            }
            print(self.lon)
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            completion(Float(self.lon))
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location : [CLLocation]){
        guard let location = location.first else{
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
}
