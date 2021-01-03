//
//  Home.swift
//  CoreLocationSearchBar
//
//  Created by Maxim Macari on 3/1/21.
//

import SwiftUI
import CoreLocation

struct Home: View {
    
    @StateObject var mapData = MapViewModel()
    
    
    //Location manager
    @State var locationManager = CLLocationManager()
    
    
    var body: some View {
        ZStack{
            
            
            
            
            //MapView
            MapView()
                //using it as environmentObject so that it can be used in its subViews
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                
                VStack(spacing: 0){
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $mapData.searchText)
                            .colorScheme(.light)
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    //Displaying results
                    
                    if !mapData.places.isEmpty && mapData.searchText != "" {
                        
                        ScrollView(showsIndicators: false){
                            VStack(spacing: 15){
                                ForEach(mapData.places){ place in
                                    
                                    Text(place.placemark.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .onTapGesture{
                                            mapData.selectPlace(place: place)
                                        }
                                    
                                    Divider()
                                }
                            }
                            .padding(.top)
                        }
                        .background(
                            Color.white
                        )
                    }
                }
                .padding()
                
                Spacer()
                
                VStack{
                    Button(action: {
                        mapData.focusLocation()
                    }, label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    })
                    
                    Button(action: {
                        mapData.updateMapType()
                    }, label: {
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
                
            }
                
        }
        .onAppear(perform: {
            //setting delegate
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
            
        })
        //Permisssion denied alert
        .alert(isPresented: $mapData.permissionDenied, content: {
            Alert(title: Text("Permission Denied"), message: Text("Please enable permission in app settings."), dismissButton: .default(Text("Goto seettings."), action: {
                //Redirecting to user seettings
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        })
        .onChange(of: mapData.searchText, perform: { value in
            //Searching places
            
            //you can use your onw deelay time to avoid continuous search request
            let delay = 0.8
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if value == mapData.searchText {
                    //Search
                    self.mapData.searchQurey()
                }
            }
        })
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
