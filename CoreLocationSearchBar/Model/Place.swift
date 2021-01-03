//
//  Place.swift
//  CoreLocationSearchBar
//
//  Created by Maxim Macari on 3/1/21.
//

import SwiftUI
import MapKit

struct Place: Identifiable {
    var id = UUID().uuidString
    var placemark: CLPlacemark
}

