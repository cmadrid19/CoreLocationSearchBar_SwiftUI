//
//  MapViewModel.swift
//  CoreLocationSearchBar
//
//  Created by Maxim Macari on 3/1/21.
//

import SwiftUI
import MapKit
import CoreLocation

//All map data goes here

class MapViewModel: NSObject,ObservableObject, CLLocationManagerDelegate {
    
    @Published var mapView = MKMapView()
    
    //Region
    @Published var region: MKCoordinateRegion!
    
    //Alert
    @Published var permissionDenied = false
    
    //map type
    @Published var mapType: MKMapType = MKMapType.standard
    
//    SearchText
    @Published var searchText = ""
    
    //Searched places
    @Published var places: [Place] = []
    
    
    //Updating map type
    func updateMapType() {
        if mapType == .standard {
            mapType = .hybrid
            mapView.mapType = mapType
        } else {
            mapType = .standard
            mapView.mapType = mapType
        }
        
    }
    
    //focus location
    func focusLocation(){
        guard let _ = region else {
             return
        }
        
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    //Search places
    func searchQurey() {
        
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        //Ftch
        MKLocalSearch(request: request).start { (response, err) in
            guard let result = response else {
                return
            }
            
            self.places = result.mapItems.compactMap({ (item) -> Place? in
                return Place(placemark: item.placemark)
            })
            
        }
    }
    
    
    // pick search results
    
    func selectPlace(place: Place) {
        //Showing pin on map
        
        searchText = ""
        
        guard let coordinate = place.placemark.location?.coordinate else {
            return
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.placemark.name ?? "No name"
        
        //Removing all old ones
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pointAnnotation)
        
        //moving map to that new location
        
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
 
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //Cheking permissions
        switch manager.authorizationStatus {
        case .denied:
            //Alert
            permissionDenied.toggle()
        case .notDetermined:
            // request
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            //if permission given
            manager.requestLocation()
        default:
            ()
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        //error
        print(error.localizedDescription)
    }
    
    //getting usre Region
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        //updating map...
        self.mapView.setRegion(self.region, animated: true)
        
        //Smooth animations
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
}
